import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageSellersScreen extends StatefulWidget {
  @override
  _ManageSellersScreenState createState() => _ManageSellersScreenState();
}

class _ManageSellersScreenState extends State<ManageSellersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = "";

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
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Sellers"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search sellers...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

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
                            ),
                          ],
                        ),
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
