import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';


class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isUnreadOnly = false;

  void toggleUnreadOnly(bool value) {
    setState(() {
      isUnreadOnly = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search bar
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 10),
              // Row for Unread only switch and Filters button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Switch(
                        value: isUnreadOnly,
                        onChanged: toggleUnreadOnly,
                        activeColor: Colors.blue,
                      ),
                      Text(
                        "Unread only",
                        style: TextStyle(
                          color: isUnreadOnly ? Colors.blue : Colors.black,
                          fontWeight: isUnreadOnly ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.filter_list),
                    label: Text("Filters"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              Slidable(
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        // Add action to archive notification
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.archive,
                      label: 'Archive',
                    ),
                  ],
                ),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        Provider.of<NotificationProvider>(context,
                                listen: false)
                            .clearNotifications();
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/me.jpg'), // Adjust to your profile image
                  ),
                  title: Text(
                    "Adi added you to MIT team",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Join the conversation!"),
                  trailing: Text("Yesterday"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
