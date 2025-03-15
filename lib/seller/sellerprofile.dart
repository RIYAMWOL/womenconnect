import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:womenconnect/user/choosescreen.dart';
import 'package:womenconnect/seller/edit_sellerprofile.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SellerProfilePage extends StatefulWidget {
  @override
  _SellerProfilePageState createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  User? _user;
  Map<String, dynamic>? _sellerData;
  File? _image;
  String? _profileImageUrl;

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
        setState(() {
          _sellerData = sellerDoc.data() as Map<String, dynamic>?;
          _profileImageUrl = _sellerData?["profileImage"] ?? "";
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
      });

      try {
        // Upload to Firebase Storage
        Reference ref = _storage.ref().child('seller_profiles/${_user!.uid}.jpg');
        UploadTask uploadTask = ref.putFile(imageFile);
        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        // Update Firestore
        await _firestore.collection('sellers').doc(_user!.uid).update({
          'profileImage': imageUrl,
        });

        setState(() {
          _profileImageUrl = imageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile image updated successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading image: $e")),
        );
      }
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
        title: const Text("Seller Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _sellerData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image Upload
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.blueGrey[200],
                      backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                          ? NetworkImage(_profileImageUrl!)
                          : const AssetImage("assets/default_avatar.png") as ImageProvider,
                      child: _image == null && (_profileImageUrl == null || _profileImageUrl!.isEmpty)
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
                          _buildProfileText("Name", _sellerData!["name"]),
                          _buildProfileText("Email", _sellerData!["email"]),
                          _buildProfileText("Phone", _sellerData!["phone"]),
                          _buildProfileText("Shop Name", _sellerData!["shopName"]),
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
