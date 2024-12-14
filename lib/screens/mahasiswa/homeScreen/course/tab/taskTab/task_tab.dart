import 'package:flutter/material.dart';
import 'task_list.dart'; // Import komponen daftar tugas
import 'task_tab_buttons.dart'; // Import komponen tombol navigasi
import 'helpers/task_helpers.dart'; // Import fungsi utilitas

class TaskTab extends StatefulWidget {
  final String courseName;
  final List<Map<String, dynamic>> tasks;

  TaskTab({required this.courseName, required this.tasks});

  @override
  _TaskTabState createState() => _TaskTabState();
}

class _TaskTabState extends State<TaskTab> {
  String selectedTab = "Mendatang";

  @override
  Widget build(BuildContext context) {
    final upcomingTasks = widget.tasks
        .where((task) => !task['isComplete'] && !isPastDue(task))
        .toList();
    final overdueTasks = widget.tasks
        .where((task) => !task['isComplete'] && isPastDue(task))
        .toList();
    final completedTasks =
        widget.tasks.where((task) => task['isComplete']).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Cari berdasarkan judul tugas",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                // Logika pencarian (opsional)
              });
            },
          ),
        ),
        TaskTabButtons(
          selectedTab: selectedTab,
          onTabSelected: (tab) {
            setState(() {
              selectedTab = tab;
            });
          },
          upcomingCount: upcomingTasks.length,
          overdueCount: overdueTasks.length,
          completedCount: completedTasks.length,
        ),
        Expanded(
          child: TaskList(
            tasks: selectedTab == "Mendatang"
                ? upcomingTasks
                : selectedTab == "Lewat Jatuh Tempo"
                    ? overdueTasks
                    : completedTasks,
            emptyMessage: _getEmptyMessage(selectedTab),
            courseName: widget.courseName,
            onTaskCompleted: _onTaskCompleted,
          ),
        ),
      ],
    );
  }

  void _onTaskCompleted(String taskTitle) {
    setState(() {
      final taskIndex = widget.tasks.indexWhere((t) => t['title'] == taskTitle);
      if (taskIndex != -1) {
        final completedTask = widget.tasks.removeAt(taskIndex);
        completedTask['isComplete'] = true;
        widget.tasks.add(completedTask);
      }
    });
  }

  String _getEmptyMessage(String tabName) {
    switch (tabName) {
      case "Lewat Jatuh Tempo":
        return "Tidak ada tugas yang lewat jatuh tempo.";
      case "Selesai":
        return "Tidak ada tugas selesai.";
      default:
        return "Tidak ada tugas mendatang pada saat ini.";
    }
  }
}
