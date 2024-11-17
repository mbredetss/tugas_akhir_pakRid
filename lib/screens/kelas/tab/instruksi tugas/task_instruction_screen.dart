import 'package:flutter/material.dart';

class TaskInstructionScreen extends StatelessWidget {
  final String courseName;
  final String taskTitle;
  final String dueDate;
  final submissionDate;
  final String instructions;
  final bool isComplete;

  TaskInstructionScreen({
    required this.courseName,
    required this.taskTitle,
    required this.dueDate,
    required this.submissionDate,
    required this.instructions,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(courseName), // Menampilkan nama mata kuliah
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isComplete) // Menampilkan teks 'Dikumpulkan pada $dueDate' jika isComplete true
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                width: double.infinity,
                color: Colors.yellow[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Dikumpulkan pada $submissionDate',
                        style: TextStyle(color: Colors.black54),
                        overflow: TextOverflow
                            .ellipsis, // Menambahkan elipsis jika teks terlalu panjang
                      ),
                    ),
                    Icon(Icons.check, color: Colors.green),
                  ],
                ),
              ),
            SizedBox(height: 16),
            Text(
              taskTitle,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Jatuh tempo $dueDate',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Text(
              'Instruksi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              instructions,
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.attach_file),
                  label: Text("Lampirkan"),
                  onPressed: () {
                    // Tambahkan logika untuk melampirkan file
                  },
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text("Baru"),
                  onPressed: () {
                    // Tambahkan logika untuk menambahkan tugas baru
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
