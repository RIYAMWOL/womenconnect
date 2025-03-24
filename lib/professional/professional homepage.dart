import 'package:flutter/material.dart';
import 'package:womenconnect/professional/professionals_profile.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  int _selectedIndex = 0; // Track selected tab

  // List of pages corresponding to each navigation tab
  final List<Widget> _pages = [
    DoctorDashboard(), // Updated doctor dashboard
    ProfessionalProfilePage (),
    Center(child: Text("Appointments Page", style: TextStyle(fontSize: 20))),
    Center(child: Text("Prescriptions Page", style: TextStyle(fontSize: 20))),
    Center(child: Text("Reports & Records Page", style: TextStyle(fontSize: 20))),
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
        title: const Text("Doctor Dashboard"),
        backgroundColor: Colors.blue,
      ),
      body: _pages[_selectedIndex], // Display selected page

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Appointments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: "Prescriptions",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Records",
          ),
        ],
      ),
    );
  }
}

// New Doctor Dashboard with Grid Layout
class DoctorDashboard extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = [
    {"icon": Icons.person, "label": "Profile", "color": Colors.blue},
    {"icon": Icons.calendar_today, "label": "Appointments", "color": Colors.green},
    {"icon": Icons.medical_services, "label": "Prescriptions", "color": Colors.red},
    {"icon": Icons.receipt_long, "label": "Reports & Records", "color": Colors.orange},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Welcome, Doctor!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Manage your profile, appointments, and patient records efficiently.",
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
