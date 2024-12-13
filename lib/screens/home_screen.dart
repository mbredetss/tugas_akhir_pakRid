import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../providers/notification_provider.dart';
import 'homeScreen/class_screen.dart';
import 'chatScreen/chat_list_screen.dart';
import 'notificationScreen/notification_screen.dart';
import 'scheduleScreen/schedule_screen.dart';
import 'homeScreen/widgets/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;

  void _onBottomMenuTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getBodyContent() {
    switch (_selectedIndex) {
      case 0:
        return NotificationScreen();
      case 1:
        return ChatListScreen();
      case 2:
        return ClassScreen();
      case 3:
        return Center(child: Text("To Do List"));
      case 4:
        return ScheduleScreen(x: 2, y: 3, z: 1, a: 4, b: 2);
      default:
        return ClassScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: _getBodyContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomMenuTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Consumer<NotificationProvider>(
              builder: (context, notifier, _) => badges.Badge(
                badgeContent: Text(
                  '${notifier.notificationCount}',
                  style: TextStyle(color: Colors.white),
                ),
                child: Icon(Icons.notifications),
              ),
            ),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'ToDo List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Jadwal Kuliah',
          ),
        ],
      ),
    );
  }
}
