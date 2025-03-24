import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:womenconnect/user/choosescreen.dart';
import 'package:womenconnect/seller/edit_sellerprofile.dart';

class SellerProfilePage extends StatefulWidget {
  @override
  _SellerProfilePageState createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  User? _user;
  File? _image;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadProfileImage();
    }
  }

  // Function to upload the selected image to Firebase Storage
  Future<void> _uploadProfileImage() async {
    if (_image == null || _user == null) return;

    try {
      final ref = FirebaseStorage.instance.ref().child('seller_profiles/${_user!.uid}.jpg');
      await ref.putFile(_image!);
      String imageUrl = await ref.getDownloadURL();

      await _firestore.collection('sellers').doc(_user!.uid).update({
        "imageUrl": imageUrl,
      });

      setState(() {});
    } catch (e) {
      print("Image Upload Error: $e");
    }
  }

  // Logout function
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
        title: const Text("Seller Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('sellers').doc(_user!.uid).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("Profile not found"));
                }

                var sellerData = snapshot.data!.data() as Map<String, dynamic>?;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Image from Firebase Storage
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.blueGrey[200],
                          backgroundImage: _image != null
                              ? FileImage(_image!)
                              : (sellerData?["imageUrl"] != null
                                  ? NetworkImage(sellerData!["imageUrl"])
                                  : AssetImage("assets/default_avatar.png")) as ImageProvider,
                          child: _image == null
                              ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Seller Details Card
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileText("Name", sellerData?["name"] ?? "N/A"),
                              _buildProfileText("Email", sellerData?["email"] ?? "N/A"),
                              _buildProfileText("Phone", sellerData?["phone"] ?? "N/A"),
                              _buildProfileText("Date of Birth", sellerData?["dob"] ?? "N/A"),
                              _buildProfileText("Shop Name", sellerData?["shopName"] ?? "N/A"),
                              _buildProfileText(
                                "Account Approved",
                                sellerData?["approved"] == true ? "✅ Approved" : "❌ Not Approved",
                              ),
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
                            MaterialPageRoute(builder: (context) => EditSellerProfilePage()),
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
                );
              },
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
