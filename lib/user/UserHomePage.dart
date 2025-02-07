import 'package:flutter/material.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0; // Track selected tab

  // List of pages corresponding to each navigation tab
  final List<Widget> _pages = [
    HomeScreen(), // Updated home screen with grid layout
    Center(child: Text("Profile Page", style: TextStyle(fontSize: 20))),
    Center(child: Text("Accommodation Page", style: TextStyle(fontSize: 20))),
    Center(child: Text("Marketplace Page", style: TextStyle(fontSize: 20))),
    Center(child: Text("Notifications Page", style: TextStyle(fontSize: 20))),
    Center(child: Text("Appointments Page", style: TextStyle(fontSize: 20))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update selected tab index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WomenConnect"),
        backgroundColor: Colors.green,
      ),
      body: _pages[_selectedIndex], // Display selected page

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
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
            icon: Icon(Icons.store),
            label: "Marketplace",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifications",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Appointments",
          ),
        ],
      ),
    );
  }
}

// New Home Screen with Dashboard-Style Grid Layout
class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = [
    {"icon": Icons.person, "label": "Profile", "color": Colors.blue},
    {"icon": Icons.hotel, "label": "Accommodation", "color": Colors.orange},
    {"icon": Icons.store, "label": "Marketplace", "color": Colors.purple},
    {"icon": Icons.notifications, "label": "Notifications", "color": Colors.red},
    {"icon": Icons.calendar_today, "label": "Appointments", "color": Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Welcome to WomenConnect!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Explore the available features below.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columns
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.2,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Handle navigation based on index
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Opening ${menuItems[index]['label']}")),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: menuItems[index]["color"],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(menuItems[index]["icon"], size: 40, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          menuItems[index]["label"],
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
