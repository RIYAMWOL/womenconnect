import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminViewOrdersScreen extends StatefulWidget {
  @override
  _AdminViewOrdersScreenState createState() => _AdminViewOrdersScreenState();
}

class _AdminViewOrdersScreenState extends State<AdminViewOrdersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _markAsDelivered(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({'status': 'Delivered'});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order marked as delivered!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Orders"),
        backgroundColor: Colors.deepOrangeAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Filter
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Selected Date: $_selectedDate",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('orders').where('date', isEqualTo: _selectedDate).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final orders = snapshot.data!.docs;

                if (orders.isEmpty) {
                  return const Center(child: Text("No orders for the selected date."));
                }

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var order = orders[index];
                    String orderId = order.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                      child: ListTile(
                        leading: const Icon(Icons.shopping_bag, color: Colors.deepOrangeAccent, size: 30),
                        title: Text(
                          order['userName'] ?? 'No Name',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Product: ${order['productName'] ?? 'No Product'}"),
                            Text("Price: ₹${order['price'] ?? '0.00'}"),
                            Text("Status: ${order['status'] ?? 'Pending'}"),
                          ],
                        ),
                        trailing: order['status'] == 'Pending'
                            ? ElevatedButton(
                                onPressed: () => _markAsDelivered(orderId),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text("Deliver"),
                              )
                            : const Icon(Icons.check_circle, color: Colors.green),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
