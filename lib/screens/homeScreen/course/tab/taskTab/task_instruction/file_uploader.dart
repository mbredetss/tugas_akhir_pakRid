import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FileUploader {
  bool isUploading = false;

  Future<void> uploadFile(
    File file,
    String courseName,
    String taskTitle, {
    required Function(double) onProgress,
    required VoidCallback onComplete,
  }) async {
    final fileName = file.path.split('/').last;
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('uploads/$courseName/$fileName');

    isUploading = true;
    onProgress(0.0);

    try {
      final uploadTask = storageRef.putFile(file);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
      });

      await uploadTask;
      isUploading = false;
      onComplete();
    } catch (e) {
      isUploading = false;
      throw e;
    }
  }

  Widget buildUploadProgressIndicator(double progress) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(value: progress),
            SizedBox(height: 16),
            Text(
              'Mengunggah ${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
