import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class SellerSignupScreen extends StatefulWidget {
  @override
  _SellerSignupScreenState createState() => _SellerSignupScreenState();
}

class _SellerSignupScreenState extends State<SellerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool _isLoading = false;

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

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
String? profileImageUrl = await _uploadProfileImage();
      await _firestore.collection('sellers').doc(userCredential.user!.uid).set({
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "shopName": _shopNameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "dob": _dobController.text.trim(),
        'profileImage': profileImageUrl,
        "userId": userCredential.user!.uid,
        'role':'seller',
        'approved':false,
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup successful!"), backgroundColor: Colors.green),
      );

      Navigator.pop(context); // Navigate back after signup
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Signup failed"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seller Signup"), backgroundColor: Colors.deepOrangeAccent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: _profileImage != null ? MemoryImage(_profileImage!) : null,
                child: _profileImage == null ? Icon(Icons.camera_alt, color: Colors.white, size: 30) : null,
              ),
            ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.contains("@") ? null : "Enter a valid email",
              ),
              const SizedBox(height: 12),
TextFormField( 
  controller: _shopNameController,
  decoration: const InputDecoration(labelText: "Shop Name", border: OutlineInputBorder()),
  validator: (value) => value!.isEmpty ? "Enter your shop name" : null,
),
const SizedBox(height: 12),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? "Password must be 6+ characters" : null,
              ),
              const SizedBox(height: 12),

              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: "Confirm Password", border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) return "Confirm your password";
                  if (value != _passwordController.text) return "Passwords do not match";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone Number", border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.length < 10 ? "Enter a valid phone number" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(
                  labelText: "Date of Birth",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) => value!.isEmpty ? "Select your date of birth" : null,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Signup"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}