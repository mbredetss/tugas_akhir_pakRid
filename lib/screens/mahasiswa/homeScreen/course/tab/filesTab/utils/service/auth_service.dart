import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> checkUserRole() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();
      if (userDoc.docs.isNotEmpty) {
        return userDoc.docs.first['role'] == 'dosen';
      }
    }
  } catch (e) {
    print("Error fetching user role: $e");
  }
  return false;
}
