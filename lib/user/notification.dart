import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      "title": "Appointment Reminder",
      "message": "Your session with Dr. Smith is scheduled for tomorrow at 10 AM.",
      "time": DateTime.now().subtract(Duration(hours: 1)),
      "isRead": false,
      "icon": Icons.calendar_today,
      "color": Colors.blue,
    },
    {
      "title": "New Mental Health Program",
      "message": "Join our 'Healing Together' program for trauma recovery.",
      "time": DateTime.now().subtract(Duration(days: 1)),
      "isRead": false,
      "icon": Icons.self_improvement,
      "color": Colors.green,
    },
    {
      "title": "Therapist Available",
      "message": "Dr. Johnson has opened new consultation slots.",
      "time": DateTime.now().subtract(Duration(days: 2)),
      "isRead": true,
      "icon": Icons.local_hospital,
      "color": Colors.orange,
    },
    {
      "title": "Mental Health Resources",
      "message": "Read about 5 ways to cope with anxiety effectively.",
      "time": DateTime.now().subtract(Duration(days: 3)),
      "isRead": true,
      "icon": Icons.article,
      "color": Colors.purple,
    },
  ];

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]["isRead"] = true;
    });
  }

  void _deleteNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.lightBlue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _notifications.isEmpty
            ? Center(
                child: Text(
                  "No new notifications!",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Card(
                    elevation: 4,
                    shadowColor: Colors.black54,
                    color: notification["isRead"] ? Colors.white70 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: notification["color"],
                        child: Icon(notification["icon"], color: Colors.white),
                      ),
                      title: Text(
                        notification["title"],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notification["message"]),
                          SizedBox(height: 4),
                          Text(
                            DateFormat('yyyy-MM-dd – hh:mm a')
                                .format(notification["time"]),
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!notification["isRead"])
                            IconButton(
                              icon: Icon(Icons.done, color: Colors.green),
                              onPressed: () => _markAsRead(index),
                            ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteNotification(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
