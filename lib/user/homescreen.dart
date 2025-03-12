import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text(
                "Welcome to WomenConnect",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Empowering Women with Safety & Opportunities",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),

              const SizedBox(height: 20),

              // Quick Action Buttons
            

              const SizedBox(height: 20),

              // Safety & Emergency Features
              _buildSectionTitle("🛡️ Safety & Emergency"),
              _buildFeatureCard("Emergency SOS", "Quickly alert contacts & authorities", Icons.warning, Colors.red),
              _buildFeatureCard("Live Safety Alerts", "Get updates about nearby incidents", Icons.notification_important, Colors.orange),
              _buildFeatureCard("Safe Zones", "Find verified safe locations near you", Icons.map, Colors.blue),

              const SizedBox(height: 20),

              // Marketplace & Services
              _buildSectionTitle("🛍️ Featured Products & Services"),
              _buildFeatureCard("Trending Products", "Discover top-selling items", Icons.shopping_bag, Colors.green),
              _buildFeatureCard("Professional Services", "Book trusted professionals", Icons.person, Colors.purple),

              const SizedBox(height: 20),

              // Community & Engagement
              _buildSectionTitle("📢 Community & Events"),
              _buildFeatureCard("Upcoming Events", "Join workshops & skill-building sessions", Icons.event, Colors.teal),
              _buildFeatureCard("Community Discussions", "Engage in meaningful conversations", Icons.forum, Colors.indigo),

              const SizedBox(height: 20),

              // Notifications
              _buildSectionTitle("🔔 Notifications & Updates"),
              _buildFeatureCard("Order Updates", "Track your orders in real time", Icons.local_shipping, Colors.blue),
              _buildFeatureCard("Safety & News Alerts", "Stay informed about latest updates", Icons.announcement, Colors.amber),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for Quick Action Buttons
  Widget _buildQuickActionCard(IconData icon, String title) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // TODO: Add Navigation Logic
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.deepOrangeAccent),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  // Feature Card Widget
  Widget _buildFeatureCard(String title, String description, IconData icon, Color color) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description, style: TextStyle(color: Colors.grey[700])),
        trailing: Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          // TODO: Add Navigation Logic
        },
      ),
    );
  }
}
