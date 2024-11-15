import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/page_slider.dart';
import 'notification_screen.dart';
import 'schedule_screen.dart';
import 'chat_list_screen.dart';
import 'kelas/course_detail_screen.dart';
import 'package:badges/badges.dart' as badges;
import '../utils/data/course_data.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() => PageSlider.autoSlide(_pageController, _currentIndex, (index) {
    setState(() {
      _currentIndex = index;
    });
  });

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
        return _buildClassScreen();
      case 3:
        return Center(child: Text("To Do List"));
      case 4:
        return ScheduleScreen(x: 2, y: 3, z: 1, a: 4, b: 2);
      default:
        return _buildClassScreen();
    }
  }

  Widget _buildClassScreen() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageSlider(
            pageController: _pageController,
            currentIndex: _currentIndex,
            images: ['atmajaya.jpg', 'fti.jpg', 'uajm.jpg'],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Available courses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...courses.map((course) => GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailScreen(
                    courseName: course['title'],
                    files: course['files'],
                  ),
                ),
              );
            },
            child: CourseCard(
              courseTitle: course['title'],
              imagePath: course['image'],
            ),
          )),
        ],
      ),
    );
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
