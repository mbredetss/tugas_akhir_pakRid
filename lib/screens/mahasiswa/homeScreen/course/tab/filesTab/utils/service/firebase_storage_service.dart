import 'package:firebase_storage/firebase_storage.dart';

Future<Map<String, List<String>>> fetchFilesAndFolders(String courseName) async {
  try {
    final storageRef = FirebaseStorage.instance.ref().child('File/$courseName');
    final ListResult result = await storageRef.listAll();

    List<String> files = result.items
        .map((item) => item.name)
        .where((name) => name != '.keep')
        .toList();
    List<String> folders = result.prefixes.map((prefix) => prefix.name).toList();

    return {'files': files, 'folders': folders};
  } catch (e) {
    print("Error fetching files/folders: $e");
    return {'files': [], 'folders': []};
  }
}
