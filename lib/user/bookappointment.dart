import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookAppointmentScreen extends StatefulWidget {
  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String? _selectedCounselor;

  final List<String> _counselors = [
    "Dr. Sarah - Trauma Counselor",
    "Dr. Emily - Mental Health Specialist",
    "Dr. Lisa - Emotional Support Counselor",
    "Dr. Rachel - Women’s Wellness Coach",
    "Dr. Anna - Psychological Therapist",
  ];

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
    String name = _nameController.text;
    String date = _dateController.text;
    String time = _timeController.text;

    if (name.isNotEmpty && date.isNotEmpty && time.isNotEmpty && _selectedCounselor != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Appointment booked with $_selectedCounselor for $name on $date at $time"),
          backgroundColor: Colors.green,
        ),
      );
      _nameController.clear();
      _dateController.clear();
      _timeController.clear();
      setState(() {
        _selectedCounselor = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Appointment"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.lightBlue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCounselor,
                decoration: InputDecoration(
                  labelText: "Select Counselor",
                  border: OutlineInputBorder(),
                ),
                items: _counselors.map((counselor) {
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
              ),
              SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Your Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: _selectDate,
                decoration: InputDecoration(
                  labelText: "Preferred Date",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _timeController,
                readOnly: true,
                onTap: _selectTime,
                decoration: InputDecoration(
                  labelText: "Preferred Time",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
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
