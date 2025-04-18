import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:womenconnect/professional/edit_professionalpofile.dart';
import 'package:womenconnect/user/choosescreen.dart';


class ProfessionalProfilePage extends StatefulWidget {
  @override
  _ProfessionalProfilePageState createState() => _ProfessionalProfilePageState();
}

class _ProfessionalProfilePageState extends State<ProfessionalProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  User? _user;
  Map<String, dynamic>? _professionalData;
  File? _image;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchProfessionalData();
  }

  Future<void> _fetchProfessionalData() async {
    if (_user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('professionals').doc(_user!.uid).get();
      setState(() {
        _professionalData = userDoc.data() as Map<String, dynamic>?;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Upload image logic goes here
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => ChooseScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text("Professional Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _professionalData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.blueGrey[200],
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : (_professionalData!["profileImage"] != null
                              ? NetworkImage(_professionalData!["profileImage"])
                              : AssetImage("assets/default_avatar.png")) as ImageProvider,
                      child: _image == null
                          ? Icon(Icons.camera_alt, size: 30, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Professional Details Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileText("Name", _professionalData!["name"]),
                          _buildProfileText("Email", _professionalData!["email"]),
                          _buildProfileText("Qualification", _professionalData!["qualification"]),
                          _buildProfileText("Contact Number", _professionalData!["contactNumber"]),
                          _buildProfileText("Consultation Fees", _professionalData!["fees"]),
                          _buildProfileText("Account Approved", _professionalData!["approved"] == true ? "Yes" : "No"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Edit Profile Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfessionalProfileScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Edit Profile", style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 20),

                  // Logout Button
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Logout", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        "$title: $value",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }
}
