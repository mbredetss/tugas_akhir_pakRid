import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLogout; // Tambahkan parameter onLogout

  CustomAppBar({required this.title, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/images/uajmlogo.png',
            height: 30,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blue,
      actions: [
        if (onLogout != null)
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: onLogout,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
