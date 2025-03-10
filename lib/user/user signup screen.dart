import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UserSignupScreen extends StatefulWidget {
  const UserSignupScreen({super.key});

  @override
  State<UserSignupScreen> createState() => _UserSignupScreenState();
}

class _UserSignupScreenState extends State<UserSignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  Uint8List? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 📸 Pick Image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImage = imageBytes;
      });
    } else {
      _showSnackBar("No image selected");
    }
  }

  // ☁ Upload Image to Cloudinary
  Future<String?> _uploadProfileImage() async {
    if (_profileImage == null) return null;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/dqaitmb01/image/upload'),
      );

      request.fields['upload_preset'] = 'women_connect_images';
      request.files.add(http.MultipartFile.fromBytes('file', _profileImage!, filename: 'profile.jpg'));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonData = jsonDecode(responseData);
        return jsonData['secure_url'];
      } else {
        _showSnackBar("Image upload failed");
        return null;
      }
    } catch (e) {
      print("Cloudinary upload error: $e");
      return null;
    }
  }

  // 📅 Select Date of Birth
  Future<void> _selectDateOfBirth(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  // 🔑 Sign Up User
  void _signUpUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final phone = _phoneController.text.trim();
    final dob = _dobController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || phone.isEmpty || dob.isEmpty) {
      _showSnackBar("Please fill all fields");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match");
      return;
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final uid = userCredential.user?.uid;

      String? profileImageUrl = await _uploadProfileImage();

      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'dob': dob,
        'uid': uid,
        'profileImage': profileImageUrl,
        'role':'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar("Sign up successful!");
      // TODO: Navigate to home screen
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "An error occurred");
    } catch (e) {
      _showSnackBar("An unexpected error occurred");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: _profileImage != null ? MemoryImage(_profileImage!) : null,
                child: _profileImage == null ? Icon(Icons.camera_alt, color: Colors.white, size: 30) : null,
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(controller: _nameController, label: 'Full Name', icon: Icons.person),
            SizedBox(height: 16),
            _buildTextField(controller: _emailController, label: 'Email Address', icon: Icons.email, keyboardType: TextInputType.emailAddress),
            SizedBox(height: 16),
            _buildTextField(controller: _phoneController, label: 'Phone Number', icon: Icons.phone, keyboardType: TextInputType.phone),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectDateOfBirth(context),
              child: AbsorbPointer(child: _buildTextField(controller: _dobController, label: 'Date of Birth', icon: Icons.calendar_today)),
            ),
            SizedBox(height: 16),
            _buildTextField(controller: _passwordController, label: 'Password', icon: Icons.lock, obscureText: true),
            SizedBox(height: 16),
            _buildTextField(controller: _confirmPasswordController, label: 'Confirm Password', icon: Icons.lock, obscureText: true),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _signUpUser,
              child: Text("Sign Up"),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 80.0)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
