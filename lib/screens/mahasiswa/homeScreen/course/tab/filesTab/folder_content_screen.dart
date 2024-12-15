import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class FolderContentScreen extends StatefulWidget {
  final String courseName;
  final String folderName;

  FolderContentScreen({
    required this.courseName,
    required this.folderName,
  });

  @override
  _FolderContentScreenState createState() => _FolderContentScreenState();
}

class _FolderContentScreenState extends State<FolderContentScreen>
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
    _fetchFolderContents();

    // Animasi untuk FAB
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
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

  Future<void> _fetchFolderContents() async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final folderRef =
          storageRef.child('File/${widget.courseName}/${widget.folderName}');
      final ListResult result = await folderRef.listAll();

      List<String> files = result.items
          .map((item) => item.name)
          .where((name) => name != '.keep')
          .toList();
      List<String> folders = result.prefixes.map((prefix) => prefix.name).toList();

      setState(() {
        fileList = files;
        folderList = folders;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching folder contents: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      _showProgressDialog("Uploading $fileName");

      try {
        final ref = FirebaseStorage.instance.ref().child(
            'File/${widget.courseName}/${widget.folderName}/$fileName');
        await ref.putFile(file);
        Navigator.of(context).pop(); // Tutup dialog progress
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File berhasil diupload: $fileName')),
        );
        _fetchFolderContents();
      } catch (e) {
        Navigator.of(context).pop(); // Tutup dialog progress
        print("Error uploading file: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading file: $e')),
        );
      }
    }
  }

  Future<void> _uploadFolder() async {
    TextEditingController folderNameController = TextEditingController();

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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Folder name cannot be empty!')),
                  );
                  return;
                }

                _showProgressDialog("Creating folder $folderName");

                try {
                  final folderRef = FirebaseStorage.instance
                      .ref()
                      .child('File/${widget.courseName}/${widget.folderName}/$folderName/');
                  await folderRef.child('.keep').putData(Uint8List(0));

                  Navigator.of(context).pop(); // Tutup dialog progress
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Folder "$folderName" created successfully')),
                  );

                  Navigator.of(context).pop(); // Tutup dialog input folder
                  _fetchFolderContents(); // Refresh daftar folder
                } catch (e) {
                  Navigator.of(context).pop(); // Tutup dialog progress
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

  void _showProgressDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Expanded(child: Text(message)),
              ],
            ),
          ),
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

  void _openSubFolder(String subFolderName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderContentScreen(
          courseName: widget.courseName,
          folderName: '${widget.folderName}/$subFolderName',
        ),
      ),
    );
  }

  Future<void> _downloadAndOpenFile(String fileName) async {
    _showProgressDialog("Downloading $fileName");

    try {
      final storageRef = FirebaseStorage.instance.ref().child(
          'File/${widget.courseName}/${widget.folderName}/$fileName');
      final fileUrl = await storageRef.getDownloadURL();

      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/$fileName";

      Dio dio = Dio();
      await dio.download(fileUrl, filePath);

      Navigator.of(context).pop(); // Tutup dialog progress
      await OpenFilex.open(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File opened successfully: $fileName")),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Tutup dialog progress
      print("Error downloading/opening file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to open file: $fileName")),
      );
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.folderName}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : (fileList.isEmpty && folderList.isEmpty)
              ? Center(child: Text("No files or folders in this directory."))
              : ListView(
                  children: [
                    if (folderList.isNotEmpty) ...[
                      ...folderList.map((folderName) => ListTile(
                            leading: Icon(Icons.folder, color: Colors.amber),
                            title: Text(folderName),
                            onTap: () => _openSubFolder(folderName),
                          )),
                    ],
                    if (fileList.isNotEmpty) ...[
                      ...fileList.map((fileName) => ListTile(
                            leading: Icon(Icons.insert_drive_file, color: Colors.blue),
                            title: Text(fileName),
                            onTap: () => _downloadAndOpenFile(fileName),
                          )),
                    ],
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
