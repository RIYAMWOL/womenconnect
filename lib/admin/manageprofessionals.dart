import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageProfessionalsScreen extends StatefulWidget {
  @override
  _ManageProfessionalsScreenState createState() => _ManageProfessionalsScreenState();
}

class _ManageProfessionalsScreenState extends State<ManageProfessionalsScreen> {
  final CollectionReference professionalsCollection =
      FirebaseFirestore.instance.collection('professionals');

  void _deleteProfessional(String id) {
    professionalsCollection.doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Professional deleted successfully')),
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

  void _approveProfessional(String id) {
    professionalsCollection.doc(id).update({'approved': true});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Professional approved successfully')),
    );
  }

  void _rejectProfessional(String id) {
    professionalsCollection.doc(id).update({'approved': false});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Professional rejected')),
    );
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
              var professional = professionals[index].data() as Map<String, dynamic>;
              var docId = professionals[index].id;
              bool isApproved = professional['approved'] ?? false;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: Icon(
                    Icons.person,
                    color: isApproved ? Colors.green : Colors.deepOrangeAccent,
                  ),
                  title: Text(
                    professional['name'] ?? 'Unknown',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Specialization: ${professional['specialization'] ?? 'N/A'}'),
                      Text('Experience: ${professional['experience'] ?? 'N/A'} years'),
                      Text('Phone: ${professional['contactNumber'] ?? 'N/A'}'),
                      Text('Email: ${professional['email'] ?? 'N/A'}'),
                      Text('Availability: ${professional['availability'] ?? 'N/A'}'),
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
                        onPressed: () => _deleteProfessional(docId),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'approve') {
                            _approveProfessional(docId);
                          } else if (value == 'reject') {
                            _rejectProfessional(docId);
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'approve',
                            child: Text('Approve'),
                          ),
                          PopupMenuItem<String>(
                            value: 'reject',
                            child: Text('Reject'),
                          ),
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
    _nameController = TextEditingController(text: data['name']);
    _specializationController = TextEditingController(text: data['specialization']);
    _experienceController = TextEditingController(text: data['experience']);
    _emailController = TextEditingController(text: data['email']);
    _contactNumberController = TextEditingController(text: data['contactNumber']);
    _availabilityController = TextEditingController(text: data['availability']);
  }

  void _updateProfessional() {
    widget.professional.reference.update({
      'name': _nameController.text,
      'specialization': _specializationController.text,
      'experience': _experienceController.text,
      'email': _emailController.text,
      'contactNumber': _contactNumberController.text,
      'availability': _availabilityController.text,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Professional'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: _specializationController, decoration: InputDecoration(labelText: 'Specialization')),
            TextField(controller: _experienceController, decoration: InputDecoration(labelText: 'Experience')),
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