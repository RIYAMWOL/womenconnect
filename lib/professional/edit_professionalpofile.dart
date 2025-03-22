import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfessionalProfileScreen extends StatefulWidget {
  @override
  _EditProfessionalProfileScreenState createState() => _EditProfessionalProfileScreenState();
}

class _EditProfessionalProfileScreenState extends State<EditProfessionalProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  User? _user;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _qualificationController = TextEditingController();
  TextEditingController _contactController = TextEditingController();
  TextEditingController _feesController = TextEditingController();
  String? _imageUrl;
  XFile? _profileImage;
  Uint8List? _webImage;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchProfessionalData();
  }

  Future<void> _fetchProfessionalData() async {
    if (_user != null) {
      DocumentSnapshot doc = await _firestore.collection('professionals').doc(_user!.uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _qualificationController.text = data['qualification'] ?? '';
          _contactController.text = data['contactNumber'] ?? '';
          _feesController.text = data['fees'] ?? '';
          _imageUrl = data['profileImage'];
        });
      }
    }
  }

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
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_profileImage == null) return _imageUrl;
    
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
      }
    } catch (e) {
      print("Image upload failed: $e");
    }
    return null;
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty ||
        _qualificationController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _feesController.text.isEmpty) {
      _showSnackBar("Please fill all fields");
      return;
    }

    try {
      String? newImageUrl = await _uploadProfileImage();
      await _firestore.collection('professionals').doc(_user!.uid).update({
        'name': _nameController.text.trim(),
        'qualification': _qualificationController.text.trim(),
        'contactNumber': _contactController.text.trim(),
        'fees': _feesController.text.trim(),
        'profileImage': newImageUrl ?? _imageUrl,
      });
      _showSnackBar("Profile updated successfully!");
    } catch (e) {
      _showSnackBar("Error updating profile: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImage != null
                      ? kIsWeb && _webImage != null
                          ? MemoryImage(_webImage!) as ImageProvider
                          : FileImage(File(_profileImage!.path))
                      : (_imageUrl != null ? NetworkImage(_imageUrl!) : null),
                  child: _profileImage == null
                      ? Icon(Icons.camera_alt, size: 30, color: Colors.white)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(_nameController, "Full Name", Icons.person),
              _buildTextField(_qualificationController, "Qualification", Icons.school),
              _buildTextField(_contactController, "Contact Number", Icons.phone),
              _buildTextField(_feesController, "Consultation Fees", Icons.money),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                  backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueGrey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}
