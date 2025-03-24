import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfessionalSignupScreen extends StatefulWidget {
  const ProfessionalSignupScreen({Key? key}) : super(key: key);

  @override
  State<ProfessionalSignupScreen> createState() => _ProfessionalSignupScreenState();
}

class _ProfessionalSignupScreenState extends State<ProfessionalSignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _feesController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  XFile? _profileImage;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = imageBytes;
          _profileImage = pickedFile;
        });
      } else {
        setState(() {
          _profileImage = pickedFile;
        });
      }
    } else {
      _showSnackBar("No image selected");
    }
  }

<<<<<<< HEAD
  Future<String?> _uploadProfileImage() async {
    if (_profileImage == null) return null;

    String cloudinaryUrl = "https://api.cloudinary.com/v1_1/dwno7g81o/image/upload";
    String uploadPreset = "profile_images";

    try {
      var request = http.MultipartRequest("POST", Uri.parse(cloudinaryUrl));
      request.fields["upload_preset"] = uploadPreset;

      if (kIsWeb && _webImage != null) {
        String base64Image = base64Encode(_webImage!);
        request.fields["file"] = "data:image/png;base64,$base64Image";
      } else {
        request.files.add(await http.MultipartFile.fromPath("file", _profileImage!.path));
      }
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);
        return jsonData["secure_url"];
      } else {
        print("Cloudinary Upload Failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error uploading image: $e");
=======
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
>>>>>>> 668abf71e5ba998bdaab3d462b6d58afddf2ae82
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
    final fees = _feesController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        qualification.isEmpty ||
        contactNumber.isEmpty ||
        fees.isEmpty) {
      _showSnackBar("Please fill all fields");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match");
      return;
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
<<<<<<< HEAD

=======
String? profileImageUrl = await _uploadProfileImage();
      // Get user ID
>>>>>>> 668abf71e5ba998bdaab3d462b6d58afddf2ae82
      final uid = userCredential.user?.uid;
      String? profileImageUrl = await _uploadProfileImage();

      await _firestore.collection('professionals').doc(uid).set({
        'name': name,
        'email': email,
        'qualification': qualification,
        'contactNumber': contactNumber,
<<<<<<< HEAD
        'fees': fees,
        'uid': uid,
        'profileImage': profileImageUrl ?? "",
        'approved': false, // Default to false until admin approves
        'role': 'professional',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar("Sign up successful! Awaiting admin approval.");
=======
        'profileImage': profileImageUrl,
        'uid': uid,
        'role':'professional',
        'approved':false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar("Sign up successful!");
     
>>>>>>> 668abf71e5ba998bdaab3d462b6d58afddf2ae82
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Professional Signup",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
<<<<<<< HEAD
              children: [
                const SizedBox(height: 100),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _profileImage != null
                        ? kIsWeb && _webImage != null
                            ? MemoryImage(_webImage!) as ImageProvider
                            : FileImage(File(_profileImage!.path))
                        : null,
                    child: _profileImage == null
                        ? Icon(Icons.camera_alt, color: Colors.white, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(_nameController, 'Full Name', 'Enter your name', Icons.person),
                _buildTextField(_emailController, 'Email Address', 'Enter your email', Icons.email, TextInputType.emailAddress),
                _buildTextField(_passwordController, 'Password', 'Enter a strong password', Icons.lock, TextInputType.text, true),
                _buildTextField(_confirmPasswordController, 'Confirm Password', 'Re-enter password', Icons.lock, TextInputType.text, true),
                _buildTextField(_qualificationController, 'Qualification', 'Enter your qualification', Icons.school),
                _buildTextField(_contactController, 'Contact Number', 'Enter your number', Icons.phone, TextInputType.phone),
                _buildTextField(_feesController, 'Consultation Fees', 'Enter your fees', Icons.money, TextInputType.number),
                const SizedBox(height: 30),
=======
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
>>>>>>> 668abf71e5ba998bdaab3d462b6d58afddf2ae82
                ElevatedButton(
                  onPressed: _signUpProfessional,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 80.0),
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  ),
                  child: const Text("Sign Up", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hintText, IconData icon,
      [TextInputType keyboardType = TextInputType.text, bool obscureText = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.blueGrey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
        ),
      ),
    );
  }
}
