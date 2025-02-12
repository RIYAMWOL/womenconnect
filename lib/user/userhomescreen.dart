import 'package:flutter/material.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    ProfileScreen(),
    AccommodationScreen(),
    MarketplaceScreen(),
    AppointmentsScreen(),
    NotificationsScreen(),
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
            icon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel),
            label: "Accommodation",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Marketplace",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Appointments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            label: "Notifications",
          ),
        ],
      ),
    );
  }
}

// Placeholder Screens
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Home Screen"));
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Profile Screen"));
  }
}

class AccommodationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Accommodation Screen"));
  }
}

class MarketplaceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Marketplace Screen"));
  }
}

class AppointmentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Appointments Screen"));
  }
}

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Notifications Screen"));
  }
}