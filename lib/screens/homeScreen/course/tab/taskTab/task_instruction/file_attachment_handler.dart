import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileAttachmentHandler {
  File? selectedFile;

  Future<void> openFileExplorer() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      selectedFile = File(result.files.single.path!);
    }
  }

  void clearSelectedFile() {
    selectedFile = null;
  }

  Widget buildFileWidget({required VoidCallback onDelete}) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              selectedFile!.path.split('/').last,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
