import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:womenconnect/seller/addproduct.dart';
import 'package:womenconnect/seller/vieworder.dart';
import 'package:womenconnect/seller/sellerprofile.dart';

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

  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _getSellerDetails();
  }

  Future<void> _getSellerDetails() async {
    user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot sellerData =
          await FirebaseFirestore.instance.collection('sellers').doc(user!.uid).get();
      
      setState(() {
        sellerName = sellerData['name'] ?? "Seller";
        sellerEmail = sellerData['email'] ?? "No Email";
        _pages = [
          _buildHomeScreen(),
          SellerProfilePage(sellerName: sellerName, sellerEmail: sellerEmail),
          AddProductScreen(),
          SellerOrdersScreen(),
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.isNotEmpty ? _pages[_selectedIndex] : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.deepOrangeAccent,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "Add Product"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Orders"),
        ],
      ),
    );
  }

  // Seller Dashboard Home Screen
  Widget _buildHomeScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seller Profile Info
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.store, size: 40, color: Colors.deepOrange),
              title: Text(sellerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              subtitle: Text(sellerEmail, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 20),

          // Grid Menu for Quick Actions
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildQuickActionCard(Icons.add_box, "Add Product", 2),
              _buildQuickActionCard(Icons.shopping_cart, "Orders", 3),
              _buildQuickActionCard(Icons.person, "Profile", 1),
            ],
          ),
        ],
      ),
    );
  }

  // Quick Access Cards for Dashboard
  Widget _buildQuickActionCard(IconData icon, String title, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.deepOrangeAccent),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
