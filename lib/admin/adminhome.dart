import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    UserListScreen(),
    ManageProfessionalsScreen(),
    ManageSellersScreen(),
    ViewOrdersScreen(),
    ViewAppointmentsScreen(),
    ViewProductsScreen(), // NEW: View Products
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: "Professionals"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Sellers"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Appointments"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Products"),
        ],
      ),
    );
  }
}

