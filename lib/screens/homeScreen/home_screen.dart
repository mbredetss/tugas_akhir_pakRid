import 'package:flutter/material.dart';
import 'utils/page_slider.dart';
import 'widgets/course_card.dart';
import 'data/course_data.dart';
import 'course/course_detail_screen.dart';

class ClassScreen extends StatefulWidget {
  @override
  _ClassScreenState createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    PageSlider.autoSlide(_pageController, _currentIndex, (index) {
      setState(() {
        _currentIndex = index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
}
