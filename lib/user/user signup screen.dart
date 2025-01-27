// //   import 'package:flutter/material.dart';

// // class UserSignupScreen extends StatefulWidget {
// //   const UserSignupScreen({super.key});

// //   @override
// //   State<UserSignupScreen> createState() => _UserSignupScreenState();
// // }

// // class _UserSignupScreenState extends State<UserSignupScreen> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         decoration: const BoxDecoration(
// //           gradient: LinearGradient(
// //             colors: [Color(0xFFFDEB71), Color(0xFFF8D800)],
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //           ),
// //         ),
// //         child: SingleChildScrollView(
// //           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50.0),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.center,
// //             children: [
// //               const Text(
// //                 "Welcome!",
// //                 style: TextStyle(
// //                   fontSize: 28,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.black,
// //                 ),
// //               ),
// //               const SizedBox(height: 10),
// //               const Text(
// //                 "Create your account to get started",
// //                 style: TextStyle(fontSize: 16, color: Colors.black87),
// //                 textAlign: TextAlign.center,
// //               ),
// //               const SizedBox(height: 30),
// //               Card(
// //                 elevation: 8.0,
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(20.0),
// //                 ),
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(20.0),
// //                   child: Column(
// //                     children: [
// //                       TextField(
// //                         decoration: InputDecoration(
// //                           labelText: "Full Name",
// //                           hintText: "Enter your full name",
// //                           prefixIcon: const Icon(Icons.person),
// //                           border: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(15),
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 15),
// //                       TextField(
// //                         decoration: InputDecoration(
// //                           labelText: "Email",
// //                           hintText: "Enter your email address",
// //                           prefixIcon: const Icon(Icons.email),
// //                           border: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(15),
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 15),
// //                       TextField(
// //                         decoration: InputDecoration(
// //                           labelText: "Password",
// //                           hintText: "Enter your password",
// //                           prefixIcon: const Icon(Icons.lock),
// //                           border: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(15),
// //                           ),
// //                         ),
// //                         obscureText: true,
// //                       ),
// //                       const SizedBox(height: 15),
// //                       TextField(
// //                         decoration: InputDecoration(
// //                           labelText: "Confirm Password",
// //                           hintText: "Re-enter your password",
// //                           prefixIcon: const Icon(Icons.lock_outline),
// //                           border: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(15),
// //                           ),
// //                         ),
// //                         obscureText: true,
// //                       ),
// //                       const SizedBox(height: 30),
// //                       ElevatedButton(
// //                         onPressed: () {
// //                           // Handle sign-up logic
// //                         },
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: Colors.yellow,
// //                           padding: const EdgeInsets.symmetric(vertical: 16.0),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(15),
// //                           ),
// //                           elevation: 5,
// //                         ),
// //                         child: const Text(
// //                           'Sign Up',
// //                           style: TextStyle(
// //                             color: Colors.black,
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSignupScreen extends StatefulWidget {
  const UserSignupScreen({super.key});

  @override
  State<UserSignupScreen> createState() => _UserSignupScreenState();
}

class _UserSignupScreenState extends State<UserSignupScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Sign up the user with email and password
        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Add user details to Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'fullName': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-up successful!')),
        );

        // Navigate to another screen or clear the form
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'email-already-in-use') {
          errorMessage = 'The email is already in use.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'The password is too weak.';
        } else {
          errorMessage = 'An error occurred: ${e.message}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
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
            colors: [Color(0xFFFDEB71), Color(0xFFF8D800)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Welcome!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Create your account to get started",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            labelText: "Full Name",
                            hintText: "Enter your full name",
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            hintText: "Enter your email address",
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
                            if (value == null || value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            hintText: "Re-enter your password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
