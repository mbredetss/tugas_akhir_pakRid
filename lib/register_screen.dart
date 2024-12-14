import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _stambukController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();

  List<String> _selectedCourses = [];
  List<Map<String, dynamic>> _allCourses = [];
  String? _nameError;

  Future<void> _fetchCourses() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('courses').get();
    setState(() {
      _allCourses = snapshot.docs
          .map((doc) => {'id': doc.id, 'title': doc['title']})
          .toList();
    });
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Peringatan'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showConfirmationDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text(
          'Apakah Anda yakin semua data dan pilihan kursus sudah benar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Periksa Lagi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _register(); // Melanjutkan proses registrasi
            },
            child: Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }

  Future<void> _register() async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text.trim(),
        'stambuk': _stambukController.text.trim(),
        'address': _addressController.text.trim(),
        'dob': _dobController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'mahasiswa',
        'courses': _selectedCourses,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi berhasil! Selamat datang!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi gagal: $e')),
      );
    }
  }

  bool _validateInputs() {
    if (_nameController.text.trim().length > 10) {
      setState(() {
        _nameError = 'Nama tidak boleh lebih dari 10 karakter';
      });
      return false;
    } else {
      setState(() {
        _nameError = null;
      });
    }

    if (_nameController.text.trim().isEmpty ||
        _stambukController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _dobController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty ||
        _passwordController.text.trim() !=
            _confirmPasswordController.text.trim() ||
        _selectedCourses.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrasi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Panggilan',
                errorText: _nameError,
              ),
              onChanged: (value) {
                if (value.length > 10) {
                  setState(() {
                    _nameError = 'Nama tidak boleh lebih dari 10 karakter';
                  });
                } else {
                  setState(() {
                    _nameError = null;
                  });
                }
              },
            ),
            TextField(
              controller: _stambukController,
              decoration: InputDecoration(labelText: 'No Stambuk'),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Alamat'),
            ),
            TextField(
              controller: _dobController,
              decoration:
                  InputDecoration(labelText: 'Tanggal Lahir (DD/MM/YYYY)'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'No HP'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Kata Sandi'),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Konfirmasi Kata Sandi'),
            ),
            SizedBox(height: 20),
            Text(
              'Pilih Kursus',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _allCourses.isEmpty
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2,
                    ),
                    itemCount: _allCourses.length,
                    itemBuilder: (context, index) {
                      final course = _allCourses[index];
                      final isSelected =
                          _selectedCourses.contains(course['title']);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedCourses.remove(course['title']);
                            } else {
                              _selectedCourses.add(course['title']);
                            }
                          });
                        },
                        child: Card(
                          color: isSelected
                              ? Colors.blueAccent
                              : Colors.white,
                          elevation: 5,
                          child: Center(
                            child: Text(
                              course['title'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_validateInputs()) {
                  _showConfirmationDialog();
                } else {
                  _showErrorDialog(
                      'Harap mengisi semua data dan memilih minimal satu kursus.');
                }
              },
              child: Text('Registrasi'),
            ),
          ],
        ),
      ),
    );
  }
}
