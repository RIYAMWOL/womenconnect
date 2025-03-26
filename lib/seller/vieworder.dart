import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerOrdersScreen extends StatefulWidget {
  @override
  _SellerOrdersScreenState createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? sellerId;

  @override
  void initState() {
    super.initState();
    _fetchSellerId();
  }

  Future<void> _fetchSellerId() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        sellerId = user.uid;
      });
    } else {
      print("🔥 No seller is logged in!");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (sellerId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Orders"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Orders')
            .where('sellerId', isEqualTo: sellerId) // ✅ Fetch only orders for this seller
            .orderBy('timestamp', descending: true) // ✅ Show latest orders first
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No orders found.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          var orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var orderData = orders[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      // 🖼 Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          orderData['imageUrl'] ?? "https://via.placeholder.com/150",
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag, size: 50),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 📦 Order Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(orderData['productName'] ?? "Unknown Product",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text("Quantity: ${orderData['quantity']}", style: TextStyle(fontSize: 14)),
                            Text("Total: ₹${orderData['totalPrice']}", style: TextStyle(fontSize: 14, color: Colors.redAccent)),
                            Text("Buyer Address: ${orderData['address']}", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                            Text("Payment: ${orderData['paymentMethod']}", style: TextStyle(fontSize: 14, color: Colors.black)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
