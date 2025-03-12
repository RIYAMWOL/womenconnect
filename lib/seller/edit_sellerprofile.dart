import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditSellerProfilePage extends StatefulWidget {
  @override
  _EditSellerProfilePageState createState() => _EditSellerProfilePageState();
}

class _EditSellerProfilePageState extends State<EditSellerProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  User? _user;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _shopNameController = TextEditingController();
  
  File? _image;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchSellerData();
  }

  Future<void> _fetchSellerData() async {
    if (_user != null) {
      DocumentSnapshot sellerDoc =
          await _firestore.collection('sellers').doc(_user!.uid).get();
      if (sellerDoc.exists) {
        Map<String, dynamic> sellerData = sellerDoc.data() as Map<String, dynamic>;

        setState(() {
          _nameController.text = sellerData["name"] ?? "";
          _emailController.text = sellerData["email"] ?? "";
          _phoneController.text = sellerData["phone"] ?? "";
          _shopNameController.text = sellerData["shopName"] ?? "";
          _imageUrl = sellerData["profileImage"];
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Upload image logic to Firebase Storage (if needed)
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('sellers').doc(_user!.uid).update({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'shopName': _shopNameController.text.trim(),
          'profileImage': _imageUrl ?? _user!.photoURL, // Update image URL if changed
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );

        Navigator.pop(context); // Go back to profile page
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text("Edit Seller Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.blueGrey[200],
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (_imageUrl != null
                          ? NetworkImage(_imageUrl!)
                          : AssetImage("assets/default_avatar.png")) as ImageProvider,
                  child: _image == null
                      ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField("Name", _nameController, Icons.person),
              _buildTextField("Email", _emailController, Icons.email, readOnly: true), // Email usually can't be edited
              _buildTextField("Phone", _phoneController, Icons.phone),
              _buildTextField("Shop Name", _shopNameController, Icons.store),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Save Changes", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter your $label";
          }
          return null;
        },
      ),
    );
  }
}
