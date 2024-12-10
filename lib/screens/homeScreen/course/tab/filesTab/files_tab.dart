import 'package:flutter/material.dart';

class FilesTab extends StatelessWidget {
  final List<Map<String, String>> files;

  FilesTab({required this.files});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: files.map((file) => ListTile(
          leading: Icon(Icons.folder, color: Colors.amber),
          title: Text(file['name']!),
          subtitle: Text('Uploaded by ${file['uploadedBy']}'),
        )).toList(),
      ),
    );
  }
}
