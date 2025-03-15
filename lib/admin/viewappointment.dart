import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminManageAppointmentsScreen extends StatefulWidget {
  @override
  _AdminManageAppointmentsScreenState createState() => _AdminManageAppointmentsScreenState();
}

class _AdminManageAppointmentsScreenState extends State<AdminManageAppointmentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  void _deleteAppointment(String appointmentId) async {
    await _firestore.collection('appointments').doc(appointmentId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Appointment deleted successfully")),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Appointments"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Column(
        children: [
          // Date Picker for Filtering Appointments
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Selected Date: $_selectedDate",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.deepOrangeAccent),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
          ),

          // Appointments List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('appointments').where('date', isEqualTo: _selectedDate).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final appointments = snapshot.data!.docs;

                if (appointments.isEmpty) {
                  return const Center(child: Text("No appointments for the selected date."));
                }

                return ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    var appointment = appointments[index];
                    String appointmentId = appointment.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepOrangeAccent,
                          child: Text(appointment['token'].toString(), style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(
                          "User: ${appointment['userName'] ?? 'No Name'}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Professional: ${appointment['professionalName'] ?? 'Unknown'}"),
                            Text("Date: ${appointment['date']}"),
                            Text("Time: ${appointment['time']}"),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAppointment(appointmentId),
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
