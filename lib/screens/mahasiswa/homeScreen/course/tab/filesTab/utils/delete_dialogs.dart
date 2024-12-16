import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> showDeleteConfirmationDialog(
  BuildContext context,
  String courseName,
  String itemName, {
  required bool isFolder,
  required VoidCallback onDeleteSuccess,
}) async {
  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text(
          isFolder
              ? "Are you sure you want to delete the folder '$itemName'?"
              : "Are you sure you want to delete the file '$itemName'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Tutup dialog konfirmasi

              // Tampilkan progress bar
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(child: CircularProgressIndicator()),
              );

              try {
                final ref = FirebaseStorage.instance
                    .ref()
                    .child('File/$courseName/$itemName');

                if (isFolder) {
                  await _deleteFolder(ref);
                } else {
                  await ref.delete();
                }

                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pop(); // Tutup progress bar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Successfully deleted $itemName')),
                  );
                }

                onDeleteSuccess(); // Callback untuk menyegarkan UI
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pop(); // Tutup progress bar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete $itemName: $e'),
                    ),
                  );
                }
              } finally {
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pop(); // Pastikan progress bar ditutup
                }
              }
            },
            child: Text("Delete"),
          ),
        ],
      );
    },
  );
}

Future<void> _deleteFolder(Reference folderRef) async {
  final ListResult result = await folderRef.listAll();

  for (var fileRef in result.items) {
    await fileRef.delete();
  }

  for (var subfolderRef in result.prefixes) {
    await _deleteFolder(subfolderRef);
  }

  await folderRef.delete();
}
