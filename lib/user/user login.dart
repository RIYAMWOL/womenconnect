import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:womenconnect/admin/adminhome.dart';
import 'package:womenconnect/professional/professional%20homepage.dart';
import 'package:womenconnect/seller/seller%20homepage.dart';
import 'package:womenconnect/user/forgotpassword_screen.dart';
import 'package:womenconnect/user/userhomepage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Admin Credentials
  final String adminEmail = "admin@womenconnect.com";
  final String adminPassword = "Admin@123";

  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Check if the credentials match admin login
        if (_emailController.text.trim() == adminEmail &&
            _passwordController.text.trim() == adminPassword) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminHomeScreen()),
          );
          return;
        }

        // Normal User Login via Firebase Auth
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Fetch User Role from Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          String role = userDoc['role'];

          // Check role & navigate accordingly
          if (role == 'user') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserHomePage()),
            );
          } else if (role == 'professional') {
            DocumentSnapshot profDoc = await _firestore
                .collection('professionals')
                .doc(userCredential.user!.uid)
                .get();

            if (profDoc.exists && profDoc['approved'] == true) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DoctorHomePage()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Your professional account is not approved yet.')),
              );
              await _auth.signOut();
            }
          } else if (role == 'seller') {
            DocumentSnapshot sellerDoc = await _firestore
                .collection('sellers')
                .doc(userCredential.user!.uid)
                .get();

            if (sellerDoc.exists && sellerDoc['approved'] == true) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SellerHomePage()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Your seller account is not approved yet.')),
              );
              await _auth.signOut();
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Invalid role assigned. Contact support.')),
            );
          }
        }
// 👇 IF userDoc NOT found, check professionals and sellers directly
        else {
          // Check Professionals Collection
          DocumentSnapshot profDoc = await _firestore
              .collection('professionals')
              .doc(userCredential.user!.uid)
              .get();

          if (profDoc.exists) {
            if (profDoc['approved'] == true) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DoctorHomePage()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Your professional account is not approved yet.')),
              );
              await _auth.signOut();
            }
            return;
          }

          // Check Sellers Collection
          DocumentSnapshot sellerDoc = await _firestore
              .collection('sellers')
              .doc(userCredential.user!.uid)
              .get();

          if (sellerDoc.exists) {
            if (sellerDoc['approved'] == true) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SellerHomePage()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Your seller account is not approved yet.')),
              );
              await _auth.signOut();
            }
            return;
          }

          // If no records found
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('User data not found. Contact support.')),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "An error occurred")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          hintText: "Enter your email",
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "Enter your password",
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
