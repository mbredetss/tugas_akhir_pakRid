import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert'; // Untuk parsing JSON

import 'utils/page_slider.dart';
import 'widgets/course_card.dart';
import 'course/course_detail_screen.dart';

class ClassScreen extends StatefulWidget {
  @override
  _ClassScreenState createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  List<Map<String, dynamic>> _courses = [];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
    _startAutoSlide();
  }

  // Fungsi untuk mengambil data dari Firestore
  Future<void> _fetchCourses() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('courses').get();
      setState(() {
        _courses = snapshot.docs.map((doc) {
          final data = doc.data();

          List<Map<String, String>> files = [];
          try {
            // Parsing elemen files (array string JSON)
            final filesData = data['files'];
            if (filesData is List) {
              files = filesData
                  .map((file) {
                    // Memastikan setiap elemen array string di-parse ke List<Map<String, String>>
                    if (file is String) {
                      return (json.decode(file) as List)
                          .map((e) => Map<String, String>.from(e as Map))
                          .toList()
                          .first; // Ambil elemen pertama jika ada
                    }
                    return <String, String>{};
                  })
                  .toList();
            }
          } catch (e) {
            print('Error parsing files: $e');
          }

          return {
            'title': data['title'],
            'image': data['image'],
            'files': files,
          };
        }).toList();
      });
    } catch (error) {
      print('Error fetching courses: $error');
    }
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
          _courses.isEmpty
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: _courses.map((course) {
                    return GestureDetector(
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
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
