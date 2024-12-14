import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert'; // Tambahkan untuk parsing JSON

import 'utils/page_slider.dart';
import 'widgets/course_card.dart';
import 'course/course_detail_screen.dart';

class ClassScreen extends StatefulWidget {
  final List<String> userCourses;

  ClassScreen({required this.userCourses});

  @override
  _ClassScreenState createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  // Fungsi untuk mengambil data dari Firestore
  Future<void> _fetchCourses() async {
  if (widget.userCourses.isEmpty) {
    setState(() {
      _isLoading = false;
    });
    return;
  }

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('title', whereIn: widget.userCourses)
        .get();

    setState(() {
      _courses = snapshot.docs.map((doc) {
        final data = doc.data();
        print("Raw course data: $data"); // Debugging log

        // Ambil dan parse data files
        final rawFiles = data['files'] ?? []; // Data files (array of strings)
        print("Raw files data: $rawFiles"); // Debugging log

        List<Map<String, String>> parsedFiles = [];
        try {
          if (rawFiles is List) {
            for (var file in rawFiles) {
              if (file is String) {
                final List<dynamic> decodedFile = json.decode(file);
                parsedFiles.addAll(
                  decodedFile.map((e) => Map<String, String>.from(e)),
                );
              }
            }
          }
        } catch (e) {
          print('Error parsing files: $e');
        }

        return {
          'title': data['title'] ?? 'No Title',
          'image': data['image'] ?? '',
          'files': parsedFiles, // Masukkan hasil parsing
        };
      }).toList();
    });
  } catch (error) {
    print('Error fetching courses: $error');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
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
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : _courses.isEmpty
                  ? Center(
                      child: Text(
                        "No courses available. Please select your courses in registration.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
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
                                  files: course['files'], // Dikirim ke detail screen
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
