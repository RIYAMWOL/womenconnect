import 'package:flutter/material.dart';
import 'package:womenconnect/seller/addproduct.dart';
import 'package:womenconnect/seller/sellerdashboardscreen.dart';
import 'package:womenconnect/seller/sellerprofile.dart';
import 'package:womenconnect/seller/vieworder.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    SellerDashboardScreen(),
    SellerProfilePage(),
    AddProductScreen(),
    SellerOrdersScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.deepOrangeAccent,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: "Add Product",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Orders",
          ),
        ],
      ),
    );
  }
}
