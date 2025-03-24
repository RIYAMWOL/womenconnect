import 'package:flutter/material.dart';
import 'dart:math';

class PaymentScreen extends StatelessWidget {
  final String professionalName;
  final String date;
  final String slot;
  final double consultationFee;
  final double bookingFee;

  PaymentScreen({
    required this.professionalName,
    required this.date,
    required this.slot,
    required this.consultationFee,
    required this.bookingFee,
  });

  String generateToken() {
    final random = Random();
    return 'TOK-${random.nextInt(999999)}';
  }

  @override
  Widget build(BuildContext context) {
    final double totalAmount = consultationFee + bookingFee;
    final String token = generateToken();

    return Scaffold(
      appBar: AppBar(
        title: Text('Review & Pay'),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Schedule Section
            Text(
              'Schedule',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            ListTile(
              leading: Icon(Icons.person, color: Colors.black),
              title: Text('Professional: $professionalName'),
            ),
            ListTile(
              leading: Icon(Icons.access_time, color: Colors.black),
              title: Text('Time: $slot'),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.black),
              title: Text('Date: $date'),
            ),
            Divider(),

            // Bill Details Section
            Text(
              'Bill Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            ListTile(
              title: Text('Consultation Fee'),
              trailing: Text('\$${consultationFee.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: Text('Booking Fee'),
              trailing: Text('\$${bookingFee.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: Text(
                'Total Pay',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Divider(),

            // Token Display
            Text(
              'Your Token',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10.0),
            Center(
              child: Text(
                token,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Divider(),

            // Payment Options Section
            Text(
              'Pay with',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            ListTile(
              leading: Icon(Icons.credit_card, color: Colors.black),
              title: Text('Credit/Debit Card'),
              trailing: TextButton(
                onPressed: () {
                  // Handle change payment method
                },
                child: Text('Change'),
              ),
            ),
            SizedBox(height: 20.0),

            // Pay Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Proceed to Payment Gateway (Stripe/Razorpay)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentSuccessScreen(token: token),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Pay \$${totalAmount.toStringAsFixed(2)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Payment Success Screen
class PaymentSuccessScreen extends StatelessWidget {
  final String token;

  PaymentSuccessScreen({required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Successful'),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Your Token:',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              token,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
