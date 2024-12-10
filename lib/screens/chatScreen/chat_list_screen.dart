import 'package:flutter/material.dart';
import '../../widgets/chat_item.dart';

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat List'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          // List of chat items
          Expanded(
            child: ListView(
              children: [
                ChatItem(
                  avatarText: '2J',
                  avatarColor: Colors.green[100],
                  username: '2261017 (You)',
                  lastMessage: '',
                  lastMessageDate: '',
                ),
                ChatItem(
                  avatarText: 'S',
                  avatarImage: AssetImage('assets/profile.png'), // Placeholder image
                  username: '2261014_Sartika',
                  lastMessage: 'You: P',
                  lastMessageDate: 'Rabu',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Tambahkan logika untuk membuat chat baru
        },
        child: Icon(Icons.edit),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
