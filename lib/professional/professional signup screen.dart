import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfessionalSignupScreen extends StatefulWidget {
  const ProfessionalSignupScreen({super.key});

  @override
  State<ProfessionalSignupScreen> createState() =>
      _ProfessionalSignupScreenState();
}

class _ProfessionalSignupScreenState extends State<ProfessionalSignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _qualificationController =
      TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Uint8List? _profileImage;
  final ImagePicker _picker = ImagePicker();

 
 
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

  void _signUpProfessional() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final qualification = _qualificationController.text.trim();
    final contactNumber = _contactController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        qualification.isEmpty ||
        contactNumber.isEmpty) {
      _showSnackBar("Please fill all fields");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match");
      return;
    }

    try {
      // Create user in Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
String? profileImageUrl = await _uploadProfileImage();
      // Get user ID
      final uid = userCredential.user?.uid;

      // Store professional data in Firestore
      await _firestore.collection('professionals').doc(uid).set({
        'name': name,
        'email': email,
        'qualification': qualification,
        'contactNumber': contactNumber,
        'profileImage': profileImageUrl,
        'uid': uid,
        'role':'professional',
        'approved':false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar("Sign up successful!");
     
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "An error occurred");
    } catch (e) {
      _showSnackBar("An unexpected error occurred");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Create Professional Account",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade800, Colors.deepPurple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Form Container
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [ GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: _profileImage != null ? MemoryImage(_profileImage!) : null,
                child: _profileImage == null ? Icon(Icons.camera_alt, color: Colors.white, size: 30) : null,
              ),
            ),
                 SizedBox(height: 16),

                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  icon: Icons.person,
                ),
                SizedBox(height: 16),

                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'Enter your email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),

              
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Enter a strong password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                SizedBox(height: 16),

                // Confirm Password Field
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                SizedBox(height: 16),

                // Qualification Field
                _buildTextField(
                  controller: _qualificationController,
                  label: 'Qualification',
                  hintText: 'Enter your qualification',
                  icon: Icons.school,
                ),
                SizedBox(height: 16),

                // Contact Number Field
                _buildTextField(
                  controller: _contactController,
                  label: 'Contact Number',
                  hintText: 'Enter your contact number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 30),

                // Sign Up Button
                ElevatedButton(
                  onPressed: _signUpProfessional,
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 80.0),
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5,
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text("Sign Up"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom TextField Widget with Styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.orange),
          labelText: label,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          labelStyle: TextStyle(color: Colors.orange),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}