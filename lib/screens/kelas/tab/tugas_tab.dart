import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'instruksi tugas/task_instruction_screen.dart';
import 'package:intl/intl.dart';

class TugasTab extends StatefulWidget {
  final String courseName;
  final List<Map<String, dynamic>> tasks;

  TugasTab({required this.courseName, required this.tasks});

  @override
  _TugasTabState createState() => _TugasTabState();
}

class _TugasTabState extends State<TugasTab> with SingleTickerProviderStateMixin {
  late TabController _tabController; // Tambahkan TabController
  late List<Map<String, dynamic>> filteredTasks;
  String searchQuery = "";
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Inisialisasi TabController
    _tabController.addListener(() {
      setState(() {
        selectedTabIndex = _tabController.index;
      });
    });
    filteredTasks = widget.tasks;
  }

  @override
  void dispose() {
    _tabController.dispose(); // Hapus TabController saat widget dihancurkan
    super.dispose();
  }

  // Filter berdasarkan sub-tab
  List<Map<String, dynamic>> getFilteredTasksByTab(int tabIndex) {
    DateTime now = DateTime.now();

    if (tabIndex == 0) {
      // Mendatang: isComplete == false
      return widget.tasks.where((task) => !task['isComplete']).toList();
    } else if (tabIndex == 1) {
      // Lewat Jatuh Tempo
      return widget.tasks.where((task) {
        final dueDate = _parseDueDate(task['dueDate']);
        return dueDate != null && dueDate.isBefore(now) && !task['isComplete'];
      }).toList();
    } else if (tabIndex == 2) {
      // Selesai: isComplete == true
      return widget.tasks.where((task) => task['isComplete']).toList();
    }
    return [];
  }

  // Filter berdasarkan pencarian
  List<Map<String, dynamic>> getSearchFilteredTasks() {
    final filteredByTab = getFilteredTasksByTab(selectedTabIndex);
    if (searchQuery.isEmpty) {
      return filteredByTab;
    }
    return filteredByTab
        .where((task) =>
            task['title'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  // Parsing tanggal dari task
  DateTime? _parseDueDate(String dueDate) {
    try {
      return DateFormat("EEE dd MMM yyyy 'pukul' HH.mm", 'id_ID').parse(dueDate);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksToShow = getSearchFilteredTasks();

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "Cari berdasarkan judul tugas",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),
        // Sub-Tab Bar
        GFTabBar(
          tabBarColor: Colors.white,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          length: 3,
          controller: _tabController, // Tambahkan controller di sini
          tabs: [
            Tab(text: 'Mendatang'),
            Tab(text: 'Jatuh Tempo'),
            Tab(text: 'Selesai'),
          ],
        ),
        Expanded(
          child: tasksToShow.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: tasksToShow.length,
                  itemBuilder: (context, index) {
                    final task = tasksToShow[index];
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
                                courseName: widget.courseName,
                                taskTitle: task['title'],
                                dueDate: task['dueDate'],
                                submissionDate: task['submissionDate'],
                                instructions: task['instructions'],
                                isComplete: task['isComplete'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Tampilan kosong jika tidak ada tugas
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
            selectedTabIndex == 0
                ? "Tidak ada tugas mendatang pada saat ini."
                : selectedTabIndex == 1
                    ? "Tidak ada tugas yang lewat jatuh tempo."
                    : "Belum ada tugas yang selesai.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
