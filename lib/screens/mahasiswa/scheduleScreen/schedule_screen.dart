import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  // Tentukan jumlah baris untuk setiap hari
  final int x; // Jumlah baris untuk Senin
  final int y; // Jumlah baris untuk Selasa
  final int z; // Jumlah baris untuk Rabu
  final int a; // Jumlah baris untuk Kamis
  final int b; // Jumlah baris untuk Jumat

  ScheduleScreen({required this.x, required this.y, required this.z, required this.a, required this.b});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal Mingguan'),
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          buildDayCard("Senin", x+1, [
            ["Waktu", "Mata Kuliah", "Ruangan"],
            ["08:20 - 10:00", "Matematika", "Room 101"],
            ["10:15 - 12:00", "Fisika", "Room 102"]
          ]),
          buildDayCard("Selasa", y+1, [
            ["Waktu", "Mata Kuliah", "Ruangan"],
            ["09:00 - 10:30", "Kimia", "Room 103"],
            ["10:45 - 12:15", "Biologi", "Room 104"],
            ["13:00 - 14:30", "Bahasa Inggris", "Room 105"]
          ]),
          buildDayCard("Rabu", z+1, [
            ["Waktu", "Mata Kuliah", "Ruangan"],
            ["08:00 - 09:30", "Sejarah", "Room 106"]
          ]),
          buildDayCard("Kamis", a+1, [
            ["Waktu", "Mata Kuliah", "Ruangan"],
            ["09:30 - 11:00", "Ekonomi", "Room 107"],
            ["11:15 - 12:45", "Sosiologi", "Room 108"],
            ["14:00 - 15:30", "Geografi", "Room 109"],
            ["15:45 - 17:15", "Pendidikan Jasmani", "Room 110"]
          ]),
          buildDayCard("Jumat", b+1, [
            ["Waktu", "Mata Kuliah", "Ruangan"],
            ["08:30 - 10:00", "Komputer", "Room 111"],
            ["10:15 - 11:45", "Kesenian", "Room 112"]
          ]),
        ],
      ),
    );
  }

  Widget buildDayCard(String day, int rowCount, List<List<String>> scheduleData) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Table(
              border: TableBorder.all(),
              children: List.generate(rowCount, (rowIndex) {
                return TableRow(
                  children: List.generate(3, (colIndex) {
                    return Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        scheduleData.length > rowIndex ? scheduleData[rowIndex][colIndex] : '',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
