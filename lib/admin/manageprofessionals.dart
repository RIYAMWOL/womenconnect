import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageProfessionalsScreen extends StatefulWidget {
  @override
  _ManageProfessionalsScreenState createState() => _ManageProfessionalsScreenState();
}

class _ManageProfessionalsScreenState extends State<ManageProfessionalsScreen> {
  final CollectionReference professionalsCollection =
      FirebaseFirestore.instance.collection('professionals');

  // ✅ Confirm before deleting a professional
  void _confirmDeleteProfessional(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Professional?"),
        content: Text("Are you sure you want to delete this professional?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await professionalsCollection.doc(id).delete();
              Navigator.pop(context);
              _showSnackBar("Professional deleted successfully");
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _updateProfessional(DocumentSnapshot professional) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateProfessionalScreen(professional: professional),
      ),
    );
  }

  void _approveProfessional(String id) async {
    await professionalsCollection.doc(id).update({'approved': true});
    _showSnackBar("Professional approved successfully");
  }

  void _rejectProfessional(String id) async {
    await professionalsCollection.doc(id).update({'approved': false});
    _showSnackBar("Professional rejected");
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Professionals'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: professionalsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No professionals found"));
          }

          var professionals = snapshot.data!.docs;

          return ListView.builder(
            itemCount: professionals.length,
            itemBuilder: (context, index) {
              var professionalData = professionals[index].data() as Map<String, dynamic>;
              var docId = professionals[index].id;
              bool isApproved = professionalData['approved'] ?? false;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: ListTile(
                  leading: Icon(Icons.person, color: isApproved ? Colors.green : Colors.deepOrangeAccent),
                  title: Text(
                    professionalData['name'] ?? 'Unknown',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Specialization: ${professionalData['specialization'] ?? 'N/A'}'),
                      Text('Experience: ${professionalData['experience'] ?? '0'} years'),
                      Text('Phone: ${professionalData['contactNumber'] ?? 'N/A'}'),
                      Text('Email: ${professionalData['email'] ?? 'N/A'}'),
                      Text('Availability: ${professionalData['availability'] ?? 'N/A'}'),
                      Text('Status: ${isApproved ? 'Approved' : 'Pending'}'),
                    ],
                  ),
                  trailing: Wrap(
                    spacing: 12,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.deepOrangeAccent),
                        onPressed: () => _updateProfessional(professionals[index]),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteProfessional(docId),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'approve') {
                            _approveProfessional(docId);
                          } else if (value == 'reject') {
                            _rejectProfessional(docId);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'approve', child: Text('Approve')),
                          PopupMenuItem(value: 'reject', child: Text('Reject')),
                        ],
                        icon: Icon(Icons.more_vert, color: Colors.deepOrangeAccent),
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

class UpdateProfessionalScreen extends StatefulWidget {
  final DocumentSnapshot professional;

  UpdateProfessionalScreen({required this.professional});

  @override
  _UpdateProfessionalScreenState createState() => _UpdateProfessionalScreenState();
}

class _UpdateProfessionalScreenState extends State<UpdateProfessionalScreen> {
  late TextEditingController _nameController;
  late TextEditingController _specializationController;
  late TextEditingController _experienceController;
  late TextEditingController _emailController;
  late TextEditingController _contactNumberController;
  late TextEditingController _availabilityController;

  @override
  void initState() {
    super.initState();
    var data = widget.professional.data() as Map<String, dynamic>;

    _nameController = TextEditingController(text: data['name'] ?? '');
    _specializationController = TextEditingController(text: data['specialization'] ?? '');
    _experienceController = TextEditingController(text: data['experience']?.toString() ?? '0');
    _emailController = TextEditingController(text: data['email'] ?? '');
    _contactNumberController = TextEditingController(text: data['contactNumber'] ?? '');
    _availabilityController = TextEditingController(text: data['availability'] ?? '');
  }

  void _updateProfessional() async {
    await widget.professional.reference.update({
      'name': _nameController.text,
      'specialization': _specializationController.text,
      'experience': int.tryParse(_experienceController.text) ?? 0,
      'email': _emailController.text,
      'contactNumber': _contactNumberController.text,
      'availability': _availabilityController.text,
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Professional details updated!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Professional'), backgroundColor: Colors.deepOrangeAccent),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: _specializationController, decoration: InputDecoration(labelText: 'Specialization')),
            TextField(controller: _experienceController, decoration: InputDecoration(labelText: 'Experience'), keyboardType: TextInputType.number),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _contactNumberController, decoration: InputDecoration(labelText: 'Phone')),
            TextField(controller: _availabilityController, decoration: InputDecoration(labelText: 'Availability')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfessional,
              child: Text('Update Professional'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent),
            ),
          ],
        ),
      ),
    );
  }
}
