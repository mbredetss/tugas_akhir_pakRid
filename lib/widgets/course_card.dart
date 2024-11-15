import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class CourseCard extends StatelessWidget {
  final String courseTitle;
  final String imagePath;

  CourseCard({required this.courseTitle, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return GFCard(
      boxFit: BoxFit.cover,
      title: GFListTile(
        titleText: courseTitle,
        description: Text("AW 2024/2025"),
      ),
      content: Container(
        height: 150,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
