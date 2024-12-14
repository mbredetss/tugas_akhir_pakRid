import 'package:flutter/material.dart';

class ChatItem extends StatelessWidget {
  final String avatarText;
  final ImageProvider? avatarImage;
  final Color? avatarColor;
  final String username;
  final String lastMessage;
  final String lastMessageDate;

  ChatItem({
    required this.avatarText,
    this.avatarImage,
    this.avatarColor,
    required this.username,
    required this.lastMessage,
    required this.lastMessageDate,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: avatarColor,
        backgroundImage: avatarImage,
        child: avatarImage == null
            ? Text(
                avatarText,
                style: TextStyle(color: Colors.black),
              )
            : null,
      ),
      title: Text(username),
      subtitle: Text(lastMessage),
      trailing: Text(lastMessageDate),
    );
  }
}
