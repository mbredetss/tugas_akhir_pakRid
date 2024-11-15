import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/data/post_data.dart';

class PostTab extends StatefulWidget {
  final String courseName;

  PostTab({required this.courseName});

  @override
  _PostTabState createState() => _PostTabState();
}

class _PostTabState extends State<PostTab> {
  final Map<int, TextEditingController> _commentControllers = {};

  @override
  void dispose() {
    // Dispose setiap TextEditingController dalam map
    _commentControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _addComment(Post post, int index) {
    final newComment = Comment(
      username: 'Current User', // Ganti dengan username yang sesuai
      message: _commentControllers[index]!.text,
      date: DateTime.now(),
    );

    setState(() {
      post.comments.add(newComment);
      _commentControllers[index]!.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final posts = coursePosts[widget.courseName] ?? [];
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        
        // Jika controller untuk post ini belum ada, buat baru
        _commentControllers.putIfAbsent(index, () => TextEditingController());

        return Card(
          margin: EdgeInsets.all(10.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(post.description),
                SizedBox(height: 8),
                Text("Uploaded on ${dateFormat.format(post.date)}"),
                Divider(),
                Column(
                  children: post.comments.map((comment) {
                    return ListTile(
                      title: Text(comment.username),
                      subtitle: Text(comment.message),
                      trailing: Text(dateFormat.format(comment.date)),
                    );
                  }).toList(),
                ),
                TextField(
                  controller: _commentControllers[index],
                  decoration: InputDecoration(
                    hintText: "Add a comment...",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        if (_commentControllers[index]!.text.isNotEmpty) {
                          _addComment(post, index);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
