import 'package:flutter/material.dart';
import 'package:womenconnect/admin/manageprofessionals.dart';
import 'package:womenconnect/admin/managesellers.dart';
import 'package:womenconnect/admin/userlistscreen.dart';
import 'package:womenconnect/admin/viewappointment.dart';
import 'package:womenconnect/admin/vieworder.dart';
import 'package:womenconnect/admin/viewproduct.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    AdminDashboardScreen(),
    AdminViewUsersScreen(),
    ManageProfessionalsScreen(),
    ManageSellersScreen(),
    AdminViewProductsScreen(),
    AdminManageAppointmentsScreen(),
    AdminViewOrdersScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.deepOrangeAccent,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: "Professionals"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Sellers"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Products"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Appointments"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Orders"),
        ],
      ),
    );
  }
}

// -------------------------------------------
// ADMIN DASHBOARD SCREEN (HOME PAGE)
// -------------------------------------------
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome, Admin!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Manage the platform efficiently from here.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Quick Action Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildQuickActionCard(Icons.people, "Users", context, 1),
                _buildQuickActionCard(Icons.business, "Professionals", context, 2),
                _buildQuickActionCard(Icons.store, "Sellers", context, 3),
                _buildQuickActionCard(Icons.inventory, "Products", context, 4),
                _buildQuickActionCard(Icons.calendar_today, "Appointments", context, 5),
                _buildQuickActionCard(Icons.shopping_cart, "Orders", context, 6),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(IconData icon, String title, BuildContext context, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to respective section
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => _getScreenForIndex(index)),
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

  // Function to return the respective screen based on the index
  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 1:
        return AdminViewUsersScreen();
      case 2:
        return ManageProfessionalsScreen();
      case 3:
        return ManageSellersScreen();
      case 4:
        return AdminViewProductsScreen();
      case 5:
        return AdminManageAppointmentsScreen();
      case 6:
        return AdminViewOrdersScreen();
      default:
        return const AdminDashboardScreen();
    }
  }
}
