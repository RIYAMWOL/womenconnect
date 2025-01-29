import 'package:flutter/material.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WomenConnect"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to Notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to Profile
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildFeatureCard(
              context,
              title: "Home",
              icon: Icons.home,
              color: Colors.blueAccent,
              onTap: () {
                // Navigate to Home
              },
            ),
            _buildFeatureCard(
              context,
              title: "Profile",
              icon: Icons.person,
              color: Colors.greenAccent,
              onTap: () {
                // Navigate to Profile
              },
            ),
            _buildFeatureCard(
              context,
              title: "Accommodation",
              icon: Icons.hotel,
              color: Colors.orangeAccent,
              onTap: () {
                // Navigate to Accommodation
              },
            ),
            _buildFeatureCard(
              context,
              title: "Marketplace",
              icon: Icons.store,
              color: Colors.purpleAccent,
              onTap: () {
                // Navigate to Marketplace
              },
            ),
            _buildFeatureCard(
              context,
              title: "Notification",
              icon: Icons.notifications,
              color: Colors.redAccent,
              onTap: () {
                // Navigate to Notifications
              },
            ),
            _buildFeatureCard(
              context,
              title: "Appointment",
              icon: Icons.calendar_today,
              color: Colors.tealAccent,
              onTap: () {
                // Navigate to Appointment
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        color: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
