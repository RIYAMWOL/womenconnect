import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageSellersScreen extends StatefulWidget {
  @override
  _ManageSellersScreenState createState() => _ManageSellersScreenState();
}

class _ManageSellersScreenState extends State<ManageSellersScreen> {
  final CollectionReference sellersCollection =
      FirebaseFirestore.instance.collection('sellers');

<<<<<<< HEAD
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
=======
  void _updateApproval(String sellerId, bool isApproved) async {
    await _firestore.collection('sellers').doc(sellerId).update({'approved': isApproved});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isApproved ? "Seller approved" : "Seller rejected")),
    );
  }

  void _editSeller(BuildContext context, DocumentSnapshot seller) {
    TextEditingController nameController = TextEditingController(text: seller['name'] ?? '');
    TextEditingController emailController = TextEditingController(text: seller['email'] ?? '');
    TextEditingController shopNameController = TextEditingController(text: seller['shopName'] ?? '');
    TextEditingController contactController = TextEditingController(text: seller['contactNumber'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Seller"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField("Name", nameController),
                _buildTextField("Email", emailController, readOnly: true),
                _buildTextField("Shop Name", shopNameController),
                _buildTextField("Contact", contactController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _firestore.collection('sellers').doc(seller.id).update({
                  "name": nameController.text.trim(),
                  "shopName": shopNameController.text.trim(),
                  "contactNumber": contactController.text.trim(),
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Seller details updated!")),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
>>>>>>> 668abf71e5ba998bdaab3d462b6d58afddf2ae82
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

<<<<<<< HEAD
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
=======
          // Sellers List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('sellers').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final sellers = snapshot.data!.docs.where((seller) {
                  final name = seller.data().toString().contains('name') ? seller['name'].toLowerCase() : "";
                  final shopName = seller.data().toString().contains('shopName') ? seller['shopName'].toLowerCase() : "";
                  return name.contains(_searchQuery) || shopName.contains(_searchQuery);
                }).toList();

                if (sellers.isEmpty) {
                  return const Center(child: Text("No sellers found."));
                }

                return ListView.builder(
                  itemCount: sellers.length,
                  itemBuilder: (context, index) {
                    var seller = sellers[index];

                    // Handling missing fields to prevent crashes
                    String name = seller.data().toString().contains('name') ? seller['name'] : "No Name";
                    String shopName = seller.data().toString().contains('shopName') ? seller['shopName'] : "N/A";
                    String contact = seller.data().toString().contains('contactNumber') ? seller['contactNumber'] : "N/A";

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.deepOrangeAccent,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Shop: $shopName"),
                            Text("📞 Contact: $contact"),
                            seller['approved'] == true
                                ? const Text("✅ Approved", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                                : const Text("❌ Pending Approval", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (String result) {
                            if (result == 'approve') {
                              _updateApproval(seller.id, true);
                            } else if (result == 'reject') {
                              _updateApproval(seller.id, false);
                            } else if (result == 'edit') {
                              _editSeller(context, seller);
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'approve',
                              child: ListTile(leading: Icon(Icons.check, color: Colors.green), title: Text('Approve')),
                            ),
                            const PopupMenuItem<String>(
                              value: 'reject',
                              child: ListTile(leading: Icon(Icons.close, color: Colors.red), title: Text('Reject')),
                            ),
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: ListTile(leading: Icon(Icons.edit, color: Colors.blue), title: Text('Edit')),
>>>>>>> 668abf71e5ba998bdaab3d462b6d58afddf2ae82
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
