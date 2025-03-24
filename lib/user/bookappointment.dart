import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

import 'package:womenconnect/user/payment.dart';

class BookAppointmentScreen extends StatefulWidget {
  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? _selectedDate;
  String? _selectedSlot;
  String? _generatedToken;
  Map<String, dynamic>? _selectedProfessional;

  // Fetch professionals from Firestore collection "professionals"
  Future<List<Map<String, dynamic>>> _fetchProfessionals() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('professionals').get();
      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print("Error fetching professionals: $e");
      return [];
    }
  }

  // Open date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(Duration(days: 30)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null;
      });
    }
  }

  // Generate a unique token for the appointment
  void _generateToken() {
    final random = Random();
    setState(() {
      _generatedToken = (100000 + random.nextInt(900000)).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book an Appointment")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProfessionals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No professionals available"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var professional = snapshot.data![index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(professional['imageUrl'] ?? ''),
                  ),
                  title: Text(professional['name'] ?? "Unknown"),
                  subtitle: Text(professional['specialization'] ?? ""),
                  trailing: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedProfessional = professional;
                      });
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => _buildSlotSelector(),
                      );
                    },
                    child: Text("Book"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSlotSelector() {
    List<String> slots = ["10:00 AM", "10:30 AM", "11:00 AM", "11:30 AM", "12:00 PM", "12:30 PM"];
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Select Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ElevatedButton(
            onPressed: () => _selectDate(context),
            child: Text(
              _selectedDate == null
                  ? "Choose Date"
                  : "${_selectedDate!.toLocal()}".split(' ')[0],
            ),
          ),
          SizedBox(height: 10),
          Text("Available Slots", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 10,
            children: slots.map((slot) {
              return ChoiceChip(
                label: Text(slot),
                selected: _selectedSlot == slot,
                onSelected: (selected) {
                  setState(() {
                    _selectedSlot = selected ? slot : null;
                    _generateToken();
                  });
                },
              );
            }).toList(),
          ),
          if (_generatedToken != null) ...[
            SizedBox(height: 10),
            Text("Your Token: $_generatedToken",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_selectedDate != null && _selectedSlot != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                        professionalName: _selectedProfessional?['name'] ?? '',
                        date: _selectedDate != null ? "${_selectedDate!.toLocal()}".split(' ')[0] : '',
                        slot: _selectedSlot ?? '',
                        consultationFee: _selectedProfessional?['consultationFee'] ?? 0,
                        bookingFee: _selectedProfessional?['bookingFee'] ?? 0,
                        ),
                  ),
                );
              }
            },
            child: Text("Proceed"),
          ),
        ],
      ),
    );
  }
}

