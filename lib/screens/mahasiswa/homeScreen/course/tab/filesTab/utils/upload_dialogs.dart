import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

Future<void> showUploadFileDialog(
    BuildContext context, String courseName, VoidCallback onFileUploaded) async {
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
      final ref = FirebaseStorage.instance.ref().child('File/$courseName/$fileName');
      await ref.putFile(file);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File berhasil diupload: $fileName')));

      // Perbarui file list setelah upload berhasil
      onFileUploaded();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading file: $e')));
    }
  }
}

Future<void> showCreateFolderDialog(
    BuildContext context, String courseName, VoidCallback onFolderCreated) async {
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
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              String folderName = folderNameController.text.trim();
              if (folderName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Folder name cannot be empty!')));
                return;
              }

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(child: CircularProgressIndicator()),
              );

              try {
                final folderRef = FirebaseStorage.instance
                    .ref()
                    .child('File/$courseName/$folderName/');
                await folderRef.child('.keep').putData(Uint8List(0));

                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Folder created successfully')));

                // Perbarui folder list setelah folder berhasil dibuat
                onFolderCreated();
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating folder: $e')));
              }
            },
            child: Text("Create"),
          ),
        ],
      );
    },
  );
}
