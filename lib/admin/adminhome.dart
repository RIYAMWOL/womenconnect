import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildAdminCard(
              title: 'Manage Users',
              icon: Icons.people,
              color: Colors.blue,
              onTap: () {},
            ),
            _buildAdminCard(
              title: 'Manage Professionals',
              icon: Icons.work,
              color: Colors.green,
              onTap: () {},
            ),
            _buildAdminCard(
              title: 'Manage Sellers',
              icon: Icons.store,
              color: Colors.orange,
              onTap: () {},
            ),
            _buildAdminCard(
              title: 'View Appointments',
              icon: Icons.calendar_today,
              color: Colors.red,
              onTap: () {},
            ),
            _buildAdminCard(
              title: 'View Orders',
              icon: Icons.shopping_cart,
              color: Colors.purple,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        color: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}