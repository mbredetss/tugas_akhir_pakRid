import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'notificationScreen/providers/notification_provider.dart';
import 'homeScreen/class_screen.dart';
import 'chatScreen/chat_list_screen.dart';
import 'notificationScreen/notification_screen.dart';
import 'scheduleScreen/schedule_screen.dart';
import 'homeScreen/widgets/custom_app_bar.dart';
import '../../login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  HomeScreen({required this.userName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;
  List<String> _userSelectedCourses = [];
  bool _isLoading = true; // Tambahkan indikator loading

  @override
  void initState() {
    super.initState();
    _fetchUserCourses();
  }

  // Fetch user-selected courses from Firestore
  Future<void> _fetchUserCourses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userSelectedCourses =
                List<String>.from(userDoc.data()?['courses'] ?? []);
          });
        }
      }
    } catch (e) {
      print('Error fetching user courses: $e');
    } finally {
      setState(() {
        _isLoading = false; // Hentikan loading
      });
    }
  }

  void _onBottomMenuTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getBodyContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(), // Indikator loading
      );
    }

    switch (_selectedIndex) {
      case 0:
        return NotificationScreen();
      case 1:
        return ChatListScreen();
      case 2:
        return ClassScreen(userCourses: _userSelectedCourses);
      case 3:
        return Center(child: Text("To Do List"));
      case 4:
        return ScheduleScreen(x: 2, y: 3, z: 1, a: 4, b: 2);
      default:
        return ClassScreen(userCourses: _userSelectedCourses);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Welcome, ${widget.userName}',
          onLogout: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
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
      ),
    );
  }
}
