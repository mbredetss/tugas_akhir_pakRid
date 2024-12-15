import 'package:flutter/material.dart';
import 'tab/postTab/post_tab.dart';
import 'tab/taskTab/task_tab.dart';
import 'tab/filesTab/files_tab.dart'; // Import tab baru untuk Files
import 'tab/taskTab/data/task_data.dart'; // Data tugas

class CourseDetailScreen extends StatelessWidget {
  final String courseName;
  final List<Map<String, String>> files;

  CourseDetailScreen({required this.courseName, required this.files});

  @override
  Widget build(BuildContext context) {
    final tasks = courseTasks[courseName] ?? []; // Data tugas untuk mata kuliah ini

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
            FilesTab(courseName: courseName), // Delegasikan ke modul FilesTab
            TaskTab(courseName: courseName, tasks: tasks), // Delegasikan ke TaskTab
          ],
        ),
      ),
    );
  }
}
