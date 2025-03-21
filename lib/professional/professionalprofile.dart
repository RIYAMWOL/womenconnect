import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfessionalProfileScreen extends StatefulWidget {
  const ProfessionalProfileScreen({super.key});

  @override
  State<ProfessionalProfileScreen> createState() => _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState extends State<ProfessionalProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Uint8List? _newProfileImage;
  bool _isLoading = true;

  Map<String, dynamic>? _professionalData;

  @override
  void initState() {
    super.initState();
    _fetchProfessionalData();
  }

  Future<void> _fetchProfessionalData() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final doc = await _firestore.collection('professionals').doc(uid).get();
      if (doc.exists) {
        setState(() {
          _professionalData = doc.data();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _newProfileImage = imageBytes;
      });

      // Upload to Cloudinary
      String? imageUrl = await _uploadProfileImage(imageBytes);
      if (imageUrl != null) {
        await _updateProfileImage(imageUrl);
      }
    }
  }

  Future<String?> _uploadProfileImage(Uint8List imageBytes) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/dqaitmb01/image/upload'),
      );

      request.fields['upload_preset'] = 'women_connect_images';
      request.files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: 'profile.jpg'));

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
      _showSnackBar("Image upload error");
      return null;
    }
  }

  Future<void> _updateProfileImage(String imageUrl) async {
    final uid = _auth.currentUser?.uid;
    await _firestore.collection('professionals').doc(uid).update({
      'profileImage': imageUrl,
    });
    _showSnackBar("Profile image updated!");
    _fetchProfessionalData(); // Refresh profile data
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _newProfileImage != null
                          ? MemoryImage(_newProfileImage!)
                          : (_professionalData?['profileImage'] != null
                              ? NetworkImage(_professionalData!['profileImage'])
                              : null) as ImageProvider<Object>?,
                      child: _professionalData?['profileImage'] == null && _newProfileImage == null
                          ? Icon(Icons.camera_alt, color: Colors.white, size: 40)
                          : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _professionalData?['name'] ?? '',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _professionalData?['email'] ?? '',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 20),
                  _buildInfoTile("Qualification", _professionalData?['qualification'] ?? ''),
                  _buildInfoTile("Contact Number", _professionalData?['contactNumber'] ?? ''),
                  _buildInfoTile("Account Status", _professionalData?['approved'] == true ? 'Approved' : 'Pending'),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      await _auth.signOut();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text("Logout"),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      leading: Icon(Icons.info_outline, color: Colors.deepPurple),
      title: Text(title),
      subtitle: Text(value),
      tileColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      
    );
  }
}
