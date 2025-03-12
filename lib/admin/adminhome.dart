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
    ViewAppointmentsScreen()
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
        ],
      ),
    );
  }
}

// -------------------- USERS LIST --------------------
class UserListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registered Users")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final users = snapshot.data!.docs;

          return ListView(
            children: users.map((user) {
              return Card(
                child: ListTile(
                  title: Text(user['name'] ?? 'No Name'),
                  subtitle: Text(user['email'] ?? 'No Email'),
                  leading: CircleAvatar(child: Text(user['name']?[0] ?? '?')),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// -------------------- MANAGE PROFESSIONALS --------------------
class ManageProfessionalsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ManageProfessionalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Professionals")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Professionals').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final professionals = snapshot.data!.docs;

          return ListView(
            children: professionals.map((pro) {
              return Card(
                child: ListTile(
                  title: Text(pro['name'] ?? 'No Name'),
                  subtitle: Text(pro['specialization'] ?? 'No Specialization'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await _firestore.collection('Professionals').doc(pro.id).delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Professional removed")),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// -------------------- MANAGE SELLERS --------------------
class ManageSellersScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ManageSellersScreen({super.key});

  void _updateSellerApproval(String sellerId, bool approve, BuildContext context) async {
    await _firestore.collection('Sellers').doc(sellerId).update({'approved': approve});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(approve ? "Seller approved" : "Seller rejected")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Sellers")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Sellers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final sellers = snapshot.data!.docs;

          return ListView(
            children: sellers.map((seller) {
              return Card(
                child: ListTile(
                  title: Text(seller['name'] ?? 'No Name'),
                  subtitle: Text(seller['shopName'] ?? 'No Shop Name'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _updateSellerApproval(seller.id, true, context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _updateSellerApproval(seller.id, false, context),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// -------------------- VIEW ORDERS --------------------
class ViewOrdersScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ViewOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Orders")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Orders').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final orders = snapshot.data!.docs;

          return ListView(
            children: orders.map((order) {
              return Card(
                child: ListTile(
                  title: Text("Order ID: ${order.id}"),
                  subtitle: Text("Status: ${order['status']}"),
                  trailing: Text("Total: ₹${order['total']}"),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// -------------------- VIEW APPOINTMENTS --------------------
class ViewAppointmentsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ViewAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Appointments")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Appointments').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final appointments = snapshot.data!.docs;

          return ListView(
            children: appointments.map((appointment) {
              return Card(
                child: ListTile(
                  title: Text(appointment['userName'] ?? 'No Name'),
                  subtitle: Text("Date: ${appointment['date']}"),
                  trailing: Text("Status: ${appointment['status']}"),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
