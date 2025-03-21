import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageProfessionalsScreen extends StatefulWidget {
  @override
  _ManageProfessionalsScreenState createState() => _ManageProfessionalsScreenState();
}

class _ManageProfessionalsScreenState extends State<ManageProfessionalsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = "";

  void _updateApproval(String proId, bool isApproved) async {
    await _firestore.collection('professionals').doc(proId).update({'approved': isApproved});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isApproved ? "Professional approved" : "Professional rejected")),
    );
  }

  void _editProfessional(BuildContext context, DocumentSnapshot professional) {
    TextEditingController nameController = TextEditingController(text: professional['name'] ?? '');
    TextEditingController emailController = TextEditingController(text: professional['email'] ?? '');
    TextEditingController qualificationController = TextEditingController(text: professional['qualification'] ?? '');
    TextEditingController contactController = TextEditingController(text: professional['contactNumber'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Professional"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField("Name", nameController),
                _buildTextField("Email", emailController, readOnly: true),
                _buildTextField("Qualification", qualificationController),
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
                await _firestore.collection('professionals').doc(professional.id).update({
                  "name": nameController.text.trim(),
                  "qualification": qualificationController.text.trim(),
                  "contactNumber": contactController.text.trim(),
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Professional details updated!")),
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
        title: const Text("Manage Professionals"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search professionals...",
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

          // Professionals List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('professionals').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final professionals = snapshot.data!.docs.where((pro) {
                  final name = pro.data().toString().contains('name') ? pro['name'].toLowerCase() : "";
                  final qualification = pro.data().toString().contains('qualification') ? pro['qualification'].toLowerCase() : "";
                  return name.contains(_searchQuery) || qualification.contains(_searchQuery);
                }).toList();

                if (professionals.isEmpty) {
                  return const Center(child: Text("No professionals found."));
                }

                return ListView.builder(
                  itemCount: professionals.length,
                  itemBuilder: (context, index) {
                    var pro = professionals[index];

                    // Handling missing fields to prevent crashes
                    String name = pro.data().toString().contains('name') ? pro['name'] : "No Name";
                    String qualification = pro.data().toString().contains('qualification') ? pro['qualification'] : "N/A";
                    String contact = pro.data().toString().contains('contactNumber') ? pro['contactNumber'] : "N/A";

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
                            Text("Qualification: $qualification"),
                            Text("📞 Contact: $contact"),
                            pro['approved'] == true
                                ? const Text("✅ Approved", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                                : const Text("❌ Pending Approval", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (String result) {
                            if (result == 'approve') {
                              _updateApproval(pro.id, true);
                            } else if (result == 'reject') {
                              _updateApproval(pro.id, false);
                            } else if (result == 'edit') {
                              _editProfessional(context, pro);
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
