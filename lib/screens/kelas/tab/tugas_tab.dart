import 'package:flutter/material.dart';
import 'instruksi tugas/task_instruction_screen.dart';

class TugasTab extends StatelessWidget {
  final String courseName;
  final List<Map<String, dynamic>> tasks;

  TugasTab({required this.courseName, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return tasks.isEmpty
        ? _buildEmptyState()
        : _buildTaskList(context);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            "Tidak ada tugas mendatang pada saat ini.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: EdgeInsets.all(10.0),
          child: ListTile(
            leading: Icon(Icons.assignment, color: Colors.blue),
            title: Text(task['title']),
            subtitle: Text("Dikirim pada ${task['sentTime']}"),
            trailing: task['isComplete']
                ? Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () {
              // Navigasi ke TaskInstructionScreen saat item ditekan
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskInstructionScreen(
                    courseName: courseName,
                    taskTitle: task['title'],
                    dueDate: task['dueDate'],
                    instructions: task['instructions'],
                    isComplete: task['isComplete'], // Tambahkan isComplete
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
