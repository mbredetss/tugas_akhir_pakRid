class Post {
  final String title;
  final String description;
  final DateTime date;
  final List<Comment> comments;

  Post({
    required this.title,
    required this.description,
    required this.date,
    this.comments = const [],
  });
}

class Comment {
  final String username;
  final String message;
  final DateTime date;

  Comment({required this.username, required this.message, required this.date});
}

final Map<String, List<Post>> coursePosts = {
  'Visualisasi Data': [
    Post(
      title: 'Materi baru telah diupload!',
      description: 'Material kelas uploaded by Alfredo Gormantara',
      date: DateTime(2023, 1, 30, 13, 10),
      comments: [],
    ),
    Post(
      title: 'Materi baru telah diupload!',
      description: 'Material kelas uploaded by Alfredo Gormantara',
      date: DateTime(2024, 2, 30, 13, 10),
      comments: [],
    ),
  ],
  'Teknologi Big Data': [
    Post(
      title: 'New Material Uploaded',
      description: 'Material kelas uploaded by Tri Saptadi',
      date: DateTime(2024, 1, 30, 13, 10),
      comments: [],
    ),
  ],
  //LANJUTKAN MATA KULIAH DISINI MIGHDAAAD!
};
