import 'package:flutter/material.dart';

class TaskTabButtons extends StatelessWidget {
  final String selectedTab;
  final Function(String tabName) onTabSelected;
  final int upcomingCount;
  final int overdueCount;
  final int completedCount;

  TaskTabButtons({
    required this.selectedTab,
    required this.onTabSelected,
    required this.upcomingCount,
    required this.overdueCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTabButton("Mendatang", upcomingCount > 0),
          _buildTabButton("Lewat Jatuh Tempo", overdueCount > 0),
          _buildTabButton("Selesai", completedCount > 0),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabName, bool hasTasks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: () {
          onTabSelected(tabName);
        },
        style: ElevatedButton.styleFrom(
          shape: StadiumBorder(),
          backgroundColor:
              selectedTab == tabName ? Colors.blue : Colors.grey[300],
          foregroundColor: selectedTab == tabName ? Colors.white : Colors.black,
        ),
        child: Text(
          tabName,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}
