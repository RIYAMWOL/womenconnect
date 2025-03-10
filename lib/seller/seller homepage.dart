import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:womenconnect/seller/addproduct.dart';
import 'package:womenconnect/seller/vieworder.dart';
import 'package:womenconnect/user/user%20login.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  _SellerHomePageState createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  String sellerName = "";
  String sellerEmail = "";

  @override
  void initState() {
    super.initState();
    _getSellerDetails();
  }

  Future<void> _getSellerDetails() async {
    user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot sellerData =
          await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      
      setState(() {
        sellerName = sellerData['name'] ?? "Seller";
        sellerEmail = sellerData['email'] ?? "No Email";
      });
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seller Dashboard"),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seller Profile Info
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: const Icon(Icons.person, size: 40, color: Colors.deepOrange),
                title: Text(sellerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: Text(sellerEmail, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 20),

            // Add Product Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddProductScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Add Product", style: TextStyle(fontSize: 18, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // View Orders Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewOrdersScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, color: Colors.white),
                  SizedBox(width: 10),
                  Text("View Orders", style: TextStyle(fontSize: 18, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
