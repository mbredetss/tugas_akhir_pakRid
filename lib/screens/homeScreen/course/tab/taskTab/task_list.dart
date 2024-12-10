import 'package:flutter/material.dart';
import 'task_instruction/task_instruction_screen.dart';

class TaskList extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final String emptyMessage;
  final String courseName;
  final Function(String taskTitle) onTaskCompleted;

  TaskList({
    required this.tasks,
    required this.emptyMessage,
    required this.courseName,
    required this.onTaskCompleted,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            leading: Icon(
              Icons.assignment,
              color: Colors.blue, // Atur warna sesuai kebutuhan
            ),
            title: Text(
              task['title'],
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            subtitle: Text("Dikirim pada ${task['sentTime']}"),
            trailing: task['isComplete']
                ? Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskInstructionScreen(
                    courseName: courseName,
                    taskTitle: task['title'],
                    dueDate: task['dueDate'],
                    dueTime: task['dueTime'],
                    submissionDate: task['submissionDate'],
                    instructions: task['instructions'],
                    isComplete: task['isComplete'],
                    taskId: 'unique_task_id',
                    onTaskCompleted: onTaskCompleted,
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
