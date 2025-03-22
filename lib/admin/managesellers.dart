import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageSellersScreen extends StatefulWidget {
  @override
  _ManageSellersScreenState createState() => _ManageSellersScreenState();
}

class _ManageSellersScreenState extends State<ManageSellersScreen> {
  final CollectionReference sellersCollection =
      FirebaseFirestore.instance.collection('sellers');

  /// ✅ Converts `approved` value safely
  bool _getApprovalStatus(dynamic value) {
    if (value is bool) {
      return value;
    } else if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false; // Default to false if it's null or invalid
  }

  /// ✅ Approve Seller
  void _approveSeller(String id) async {
    await sellersCollection.doc(id).update({'approved': true});
    _showSnackBar("Seller approved successfully");
  }

  /// ✅ Reject Seller
  void _rejectSeller(String id) async {
    await sellersCollection.doc(id).update({'approved': false});
    _showSnackBar("Seller rejected");
  }

  /// ✅ Show Snackbar Message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Sellers'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: sellersCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No sellers found"));
          }

          var sellers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: sellers.length,
            itemBuilder: (context, index) {
              var sellerData = sellers[index].data() as Map<String, dynamic>;
              var docId = sellers[index].id;
              bool isApproved = _getApprovalStatus(sellerData['approved']);

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: ListTile(
                  leading: Icon(Icons.store, color: isApproved ? Colors.green : Colors.deepOrangeAccent),
                  title: Text(
                    sellerData['shopName'] ?? 'Unknown Shop',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Owner: ${sellerData['name'] ?? 'N/A'}'),
                      Text('Phone: ${sellerData['phone'] ?? 'N/A'}'),
                      Text('Email: ${sellerData['email'] ?? 'N/A'}'),
                    ],
                  ),
                  trailing: isApproved
                      ? ElevatedButton(
                          onPressed: null, // Disable button if already approved
                          child: Text("Accepted"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () => _approveSeller(docId),
                              child: Text("Accept"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _rejectSeller(docId),
                              child: Text("Reject"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            ),
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
