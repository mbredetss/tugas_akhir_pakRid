import 'package:flutter/material.dart';
import 'tab/post_tab.dart';
import 'tab/tugas_tab.dart';
import '../../utils/data/task_data.dart';  // Import file data tugas

class CourseDetailScreen extends StatelessWidget {
  final String courseName;
  final List<Map<String, String>> files;

  CourseDetailScreen({required this.courseName, required this.files});

  @override
  Widget build(BuildContext context) {
    final tasks = courseTasks[courseName] ?? [];  // Ambil data tugas berdasarkan courseName

    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(courseName),
          bottom: TabBar(
            indicatorColor: Colors.blue,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Posts"),
              Tab(text: "Files"),
              Tab(text: "Tugas"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PostTab(courseName: courseName),
            _buildFilesTab(),
            TugasTab(courseName: courseName, tasks: tasks),  // Kirim data tugas ke TugasTab
          ],
        ),
      ),
    );
  }

  Widget _buildFilesTab() {
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
