import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:getwidget/getwidget.dart';
import 'screens/mahasiswa/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Fetch user data to determine role
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        final userRole = userDoc['role'] ?? 'mahasiswa';

        if (userRole == 'mahasiswa') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(userName: userDoc['name'])),
          );
        } else if (userRole == 'dosen') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Welcome Dosen! Menu Dosen')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GFAvatar(
                  backgroundImage: AssetImage('assets/images/uajmlogo.png'),
                  shape: GFAvatarShape.circle,
                  size: GFSize.LARGE * 2,
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Selamat Datang!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: GFColors.DARK,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              GFTextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Masukkan Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 20),
              GFTextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Masukkan Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 30),
              GFButton(
                onPressed: _login,
                text: 'Login',
                fullWidthButton: true,
                color: GFColors.SUCCESS,
                textStyle: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text(
                  'Belum punya akun? Daftar disini!',
                  style: TextStyle(
                    color: GFColors.PRIMARY,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}