import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/task_data.dart';

class TaskManager {
  static void moveToCompletedTab(
    String courseName,
    String taskTitle,
    Function(String taskTitle)? onTaskCompleted,
  ) {
    final currentDateTime = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    final taskIndex = courseTasks[courseName]?.indexWhere(
      (task) => task['title'] == taskTitle,
    );

    if (taskIndex != null && taskIndex >= 0) {
      courseTasks[courseName]?[taskIndex]['isComplete'] = true;
      courseTasks[courseName]?[taskIndex]['submissionDate'] = currentDateTime;

      final completedTask = courseTasks[courseName]?.removeAt(taskIndex);
      if (completedTask != null) {
        courseTasks[courseName]?.add(completedTask);
      }

      if (onTaskCompleted != null) {
        onTaskCompleted(taskTitle);
      }
    }
  }

  static Widget buildCompletionWidget(String? submissionDate) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check, color: Colors.green),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Dikumpulkan pada $submissionDate',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildLateSubmissionWidget(String? submissionDate, String? dueDate) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Terlambat dikumpulkan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Tanggal Pengumpulan: $submissionDate',
            style: TextStyle(color: Colors.black87),
          ),
          Text(
            'Batas Pengumpulan: $dueDate',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
