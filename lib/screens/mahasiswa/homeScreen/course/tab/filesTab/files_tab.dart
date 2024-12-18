import 'package:flutter/material.dart';
import 'utils/service/auth_service.dart';
import 'utils/service/firebase_storage_service.dart';
import 'utils/upload_dialogs.dart';
import 'utils/delete_dialogs.dart';
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
  bool isDosen = false;

  bool _showUploadOptions = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initialize();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  Future<void> _initialize() async {
    isDosen = await checkUserRole();
    final result = await fetchFilesAndFolders(widget.courseName);
    if (mounted) {
      setState(() {
        fileList = result['files'] ?? [];
        folderList = result['folders'] ?? [];
        isLoading = false;
      });
    }
  }

  Future<void> _refreshFilesAndFolders({String? deletedItem, bool? isFolder}) async {
    setState(() {
      // Perbarui UI langsung jika item dihapus
      if (deletedItem != null) {
        if (isFolder == true) {
          folderList.remove(deletedItem);
        } else {
          fileList.remove(deletedItem);
        }
      }
    });

    // Fetch ulang data dari server
    final result = await fetchFilesAndFolders(widget.courseName);
    if (mounted) {
      setState(() {
        fileList = result['files'] ?? [];
        folderList = result['folders'] ?? [];
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleUploadOptions() {
    setState(() {
      _showUploadOptions = !_showUploadOptions;
      _showUploadOptions
          ? _animationController.forward()
          : _animationController.reverse();
    });
  }

Widget _buildListTile({
  required String name,
  required bool isFolder,
}) {
  return ListTile(
    leading: Icon(
      isFolder ? Icons.folder : Icons.insert_drive_file,
      color: isFolder ? Colors.amber : Colors.blue,
    ),
    title: Text(name),
    trailing: isDosen
        ? PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                await showDeleteConfirmationDialog(
                  context,
                  widget.courseName,
                  name,
                  isFolder: isFolder,
                  onDeleteSuccess: () async {
                    await _refreshFilesAndFolders(
                      deletedItem: name,
                      isFolder: isFolder,
                    );
                  },
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Delete"),
                  ],
                ),
              ),
            ],
          )
        : null,
    onTap: () async {
      // Pastikan floating button ditutup sebelum navigasi
      if (_showUploadOptions) {
        await _animationController.reverse();
        setState(() {
          _showUploadOptions = false;
        });
      }

      // Navigasi ke layar folder jika itu folder
      if (isFolder) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FolderContentScreen(
              courseName: widget.courseName,
              folderName: name,
            ),
          ),
        );
      }
    },
  );
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
                    ...folderList.map((folderName) => _buildListTile(
                          name: folderName,
                          isFolder: true,
                        )),
                    ...fileList.map((fileName) => _buildListTile(
                          name: fileName,
                          isFolder: false,
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
                      onPressed: () => showCreateFolderDialog(
                        context,
                        widget.courseName,
                        _refreshFilesAndFolders,
                      ),
                      child: Icon(Icons.create_new_folder),
                      tooltip: 'Upload Folder',
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 12),
                  ScaleTransition(
                    scale: _animation,
                    child: FloatingActionButton(
                      onPressed: () => showUploadFileDialog(
                        context,
                        widget.courseName,
                        _refreshFilesAndFolders,
                      ),
                      child: Icon(Icons.upload_file),
                      tooltip: 'Upload File',
                      backgroundColor: Colors.teal,
                    ),
                  ),
                ],
                FloatingActionButton(
                  onPressed: _toggleUploadOptions,
                  child: Icon(_showUploadOptions ? Icons.close : Icons.add),
                ),
              ],
            )
          : null,
    );
  }
}
