import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Mengecek apakah tugas telah melewati batas waktu pengumpulan.
bool isPastDue(Map<String, dynamic> task) {
  if (task['dueDate'] == null || task['dueTime'] == null) return false;

  final dueDate = DateFormat("dd/MM/yyyy").parse(task['dueDate']);
  final dueTime = task['dueTime'];

  final dueDateTime = DateTime(
    dueDate.year,
    dueDate.month,
    dueDate.day,
    int.parse(dueTime.split(':')[0]),
    int.parse(dueTime.split(':')[1]),
  );

  return DateTime.now().isAfter(dueDateTime);
}

/// Mengembalikan warna ikon berdasarkan tab yang dipilih.
Color getIconColor(String tabName) {
  switch (tabName) {
    case "Lewat Jatuh Tempo":
      return Colors.red;
    case "Selesai":
      return Colors.green;
    default:
      return Colors.blue;
  }
}
