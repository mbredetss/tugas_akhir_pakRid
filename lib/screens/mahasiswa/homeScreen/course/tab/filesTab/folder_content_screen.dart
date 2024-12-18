import 'package:flutter/material.dart';
import 'utils/service/auth_service.dart';
import 'utils/service/firebase_storage_service.dart';
import 'utils/delete_dialogs.dart';
import 'utils/upload_dialogs.dart';

class FolderContentScreen extends StatefulWidget {
  final String courseName;
  final String folderName;

  const FolderContentScreen({
    Key? key,
    required this.courseName,
    required this.folderName,
  }) : super(key: key);

  @override
  _FolderContentScreenState createState() => _FolderContentScreenState();
}

class _FolderContentScreenState extends State<FolderContentScreen>
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
        AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  Future<void> _initialize() async {
    setState(() => isLoading = true);
    isDosen = await checkUserRole();
    final data = await fetchFilesAndFolders('${widget.courseName}/${widget.folderName}');
    setState(() {
      fileList = data['files']!;
      folderList = data['folders']!;
      isLoading = false;
    });
  }

  Future<void> _refreshContents({String? deletedItem, bool? isFolder}) async {
    setState(() {
      if (deletedItem != null) {
        if (isFolder == true) {
          folderList.remove(deletedItem);
        } else {
          fileList.remove(deletedItem);
        }
      }
    });

    final data = await fetchFilesAndFolders('${widget.courseName}/${widget.folderName}');
    setState(() {
      fileList = data['files']!;
      folderList = data['folders']!;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleUploadOptions() {
    setState(() {
      _showUploadOptions = !_showUploadOptions;
      _showUploadOptions ? _animationController.forward() : _animationController.reverse();
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
                    '${widget.courseName}/${widget.folderName}',
                    name,
                    isFolder: isFolder,
                    onDeleteSuccess: () async {
                      await _refreshContents(
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
                      const Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text("Delete"),
                    ],
                  ),
                ),
              ],
            )
          : null,
      onTap: isFolder
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FolderContentScreen(
                    courseName: widget.courseName,
                    folderName: '${widget.folderName}/$name',
                  ),
                ),
              )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (fileList.isEmpty && folderList.isEmpty)
              ? const Center(child: Text("No files or folders in this directory."))
              : ListView(
                  children: [
                    for (String folderName in folderList)
                      _buildListTile(name: folderName, isFolder: true),
                    for (String fileName in fileList)
                      _buildListTile(name: fileName, isFolder: false),
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
                      onPressed: () => showCreateFolderDialog(
                        context,
                        '${widget.courseName}/${widget.folderName}',
                        _refreshContents,
                      ),
                      child: const Icon(Icons.create_new_folder),
                      tooltip: 'Upload Folder',
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ScaleTransition(
                    scale: _animation,
                    child: FloatingActionButton(
                      heroTag: 'upload_file',
                      onPressed: () => showUploadFileDialog(
                        context,
                        '${widget.courseName}/${widget.folderName}',
                        _refreshContents,
                      ),
                      child: const Icon(Icons.upload_file),
                      tooltip: 'Upload File',
                      backgroundColor: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 12),
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
