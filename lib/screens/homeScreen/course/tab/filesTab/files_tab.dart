import 'package:flutter/material.dart';

class FilesTab extends StatelessWidget {
  final List<Map<String, String>> files;

  FilesTab({required this.files});

  @override
  Widget build(BuildContext context) {
    return files.isEmpty
        ? Center(
            child: Text(
              "No files available.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: files.map((file) {
                final fileName = file['name'] ?? "Unknown File";
                final uploadedBy = file['uploadedBy'] ?? "Unknown";

                return ListTile(
                  leading: Icon(Icons.folder, color: Colors.amber),
                  title: Text(
                    fileName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Uploaded by $uploadedBy'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Opening $fileName")),
                    );
                  },
                );
              }).toList(),
            ),
          );
  }
}
