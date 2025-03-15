import 'package:flutter/material.dart';
import 'package:womenconnect/seller/addproduct.dart';
import 'package:womenconnect/seller/vieworder.dart';
import 'package:womenconnect/seller/sellerprofile.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  _SellerHomePageState createState() => _SellerHomePageState();
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "Add Product"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Orders"),
        ],
      ),
    );
  }
}

class SellerDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seller Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome Seller!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildDashboardCard(Icons.add_box, "Add Product", context, 2),
                _buildDashboardCard(Icons.shopping_cart, "Orders", context, 3),
                _buildDashboardCard(Icons.person, "Profile", context, 1),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(IconData icon, String title, BuildContext context, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SellerHomePage()),
          );
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