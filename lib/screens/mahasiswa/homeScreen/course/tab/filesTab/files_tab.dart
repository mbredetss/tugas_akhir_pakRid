import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'folder_content_screen.dart';


class FilesTab extends StatefulWidget {
  final String courseName;

  FilesTab({required this.courseName});

  @override
  _FilesTabState createState() => _FilesTabState();
}

class _FilesTabState extends State<FilesTab>
    with SingleTickerProviderStateMixin {
  List<String> fileList = [];
  List<String> folderList = [];
  bool isLoading = true;
  bool isDosen = false; // Status user role

  bool _showUploadOptions = false; // Status FAB Expand/Collapse
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _checkUserRole(); // Periksa role user
    _fetchFilesAndFolders();

    // Animasi untuk FAB
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengambil role user dari Firestore
  Future<void> _checkUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Ambil data user berdasarkan email
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (userDoc.docs.isNotEmpty) {
          final role = userDoc.docs.first['role'];
          setState(() {
            isDosen = (role == 'dosen');
          });
        }
      }
    } catch (e) {
      print("Error fetching user role: $e");
    }
  }

  Future<void> _fetchFilesAndFolders() async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('File/${widget.courseName}');
      final ListResult result = await storageRef.listAll();

      List<String> files = result.items
          .map((item) => item.name)
          .where((name) => name != '.keep')
          .toList();
      List<String> folders =
          result.prefixes.map((prefix) => prefix.name).toList();

      setState(() {
        fileList = files;
        folderList = folders;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching files/folders: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

   // Fungsi menghapus item
  Future<void> _deleteItem(String itemName, bool isFolder) async {
    String itemType = isFolder ? "folder" : "file";
    String itemPath = isFolder
        ? 'File/${widget.courseName}/$itemName/'
        : 'File/${widget.courseName}/$itemName';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete $itemType"),
          content: Text("Are you sure you want to delete this $itemType?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel
              },
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  Navigator.of(context).pop(); // Close dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        Center(child: CircularProgressIndicator()),
                  );

                  final storageRef =
                      FirebaseStorage.instance.ref().child(itemPath);
                  if (isFolder) {
                    // Delete folder recursively
                    final ListResult folderContents =
                        await storageRef.listAll();
                    for (var file in folderContents.items) {
                      await file.delete();
                    }
                    for (var subFolder in folderContents.prefixes) {
                      await subFolder.delete();
                    }
                  }
                  await storageRef.delete();

                  Navigator.pop(context); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text("$itemType '$itemName' deleted successfully")),
                  );
                  _fetchFilesAndFolders();
                } catch (e) {
                  Navigator.pop(context); // Close loading dialog
                  print("Error deleting $itemType: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to delete $itemType: $e")),
                  );
                }
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('File/${widget.courseName}/$fileName');
        await ref.putFile(file);

        Navigator.pop(context); // Tutup dialog loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File berhasil diupload: $fileName')),
        );
        _fetchFilesAndFolders();
      } catch (e) {
        Navigator.pop(context); // Tutup dialog loading
        print("Error uploading file: $e");
      }
    }
  }

  Future<void> _uploadFolder() async {
    TextEditingController folderNameController = TextEditingController();

    // Menampilkan dialog input untuk nama folder
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Create New Folder"),
          content: TextField(
            controller: folderNameController,
            decoration: InputDecoration(
              labelText: "Folder Name",
              hintText: "Enter the folder name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                String folderName = folderNameController.text.trim();

                if (folderName.isEmpty) {
                  // Menampilkan pesan jika nama folder kosong
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Folder name cannot be empty!')),
                  );
                  return;
                }

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      Center(child: CircularProgressIndicator()),
                );

                // Buat folder di Firebase Storage
                try {
                  final folderRef = FirebaseStorage.instance
                      .ref()
                      .child('File/${widget.courseName}/$folderName/');
                  await folderRef.child('.keep').putData(Uint8List(0));

                  Navigator.pop(context); // Tutup dialog loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Folder "$folderName" created successfully')),
                  );

                  Navigator.of(context).pop(); // Tutup dialog
                  _fetchFilesAndFolders(); // Refresh daftar folder
                } catch (e) {
                  Navigator.pop(context); // Tutup dialog loading
                  print("Error creating folder: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create folder: $e')),
                  );
                }
              },
              child: Text("Create"),
            ),
          ],
        );
      },
    );
  }

  void _toggleUploadOptions() {
    setState(() {
      _showUploadOptions = !_showUploadOptions;
      if (_showUploadOptions) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : (fileList.isEmpty && folderList.isEmpty)
              ? Center(child: Text("No files or folders available."))
              : ListView(
                  children: [
                    ...folderList.map((folderName) => ListTile(
                          leading: Icon(Icons.folder, color: Colors.amber),
                          title: Text(folderName),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FolderContentScreen(
                                  courseName: widget.courseName,
                                  folderName: folderName,
                                ),
                              ),
                            );
                          },
                        )),
                    ...fileList.map((fileName) => ListTile(
                          leading:
                              Icon(Icons.insert_drive_file, color: Colors.blue),
                          title: Text(fileName),
                        )),
                  ],
                ),
                
      floatingActionButton: isDosen
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_showUploadOptions) ...[
                  ScaleTransition(
                    scale: _animation,
                    child: FloatingActionButton(
                      heroTag: 'upload_folder',
                      onPressed: _uploadFolder,
                      child: Icon(Icons.create_new_folder),
                      tooltip: 'Upload Folder',
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 12),
                  ScaleTransition(
                    scale: _animation,
                    child: FloatingActionButton(
                      heroTag: 'upload_file',
                      onPressed: _uploadFile,
                      child: Icon(Icons.upload_file),
                      tooltip: 'Upload File',
                      backgroundColor: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 12),
                ],
                FloatingActionButton(
                  onPressed: _toggleUploadOptions,
                  child: Icon(_showUploadOptions ? Icons.close : Icons.add),
                  tooltip: 'Upload Options',
                ),
              ],
            )
          : null,
    );
  }
}
