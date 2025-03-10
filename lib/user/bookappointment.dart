import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class BookAppointmentScreen extends StatefulWidget {
  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String? _selectedCounselor;
  int? _tokenNumber;

  final Map<String, int> _counselorTokenLimits = {
    "Dr. Sarah - Trauma Counselor": 5,
    "Dr. Emily - Mental Health Specialist": 6,
    "Dr. Lisa - Emotional Support Counselor": 4,
    "Dr. Rachel - Women’s Wellness Coach": 5,
    "Dr. Anna - Psychological Therapist": 6,
  };

  final List<String> _counselorsOnLeave = ["Dr. Emily - Mental Health Specialist"];
  final Map<String, int> _counselorAppointments = {};

  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  void _bookAppointment() {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      String date = _dateController.text;
      String time = _timeController.text;

      if (_counselorsOnLeave.contains(_selectedCounselor)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "$_selectedCounselor is on leave on $date. Please select another date or counselor."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      int currentAppointments = _counselorAppointments[_selectedCounselor] ?? 0;
      int limit = _counselorTokenLimits[_selectedCounselor]!;

      if (currentAppointments >= limit) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No slots available for $_selectedCounselor on $date. Please choose another date."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      _tokenNumber = Random().nextInt(1000) + 1;
      _counselorAppointments[_selectedCounselor!] = currentAppointments + 1;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Appointment booked with $_selectedCounselor for $name on $date at $time. Your token number is $_tokenNumber."),
          backgroundColor: Colors.green,
        ),
      );

      _nameController.clear();
      _dateController.clear();
      _timeController.clear();
      setState(() {
        _selectedCounselor = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Appointment"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCounselor,
                decoration: InputDecoration(
                  labelText: "Select Counselor",
                  border: OutlineInputBorder(),
                ),
                items: _counselorTokenLimits.keys.map((counselor) {
                  return DropdownMenuItem(
                    value: counselor,
                    child: Text(counselor),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCounselor = value;
                  });
                },
                validator: (value) => value == null ? "Please select a counselor" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Your Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Please enter your name" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _selectDate,
                decoration: InputDecoration(
                  labelText: "Preferred Date",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) => value!.isEmpty ? "Please select a date" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                onTap: _selectTime,
                decoration: InputDecoration(
                  labelText: "Preferred Time",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                validator: (value) => value!.isEmpty ? "Please select a time" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _bookAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text("Book Appointment"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
