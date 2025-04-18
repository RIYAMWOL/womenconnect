import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPasswordVisible = false;

  void _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill all fields");
      return;
    }

    try {
      // ✅ Admin login
      if (email == "riya@gmail.com" && password == "riya123") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHomeScreen()),
        );
        return;
      }

      // ✅ Firebase authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      String userId = userCredential.user!.uid;

      // ✅ Fetch user role from Firestore
      String? role = await _fetchUserRole(userId);

      if (role == "user") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserHomePage()));
      } else if (role == "seller") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SellerHomePage()));
      } else if (role == "professional") {
        bool isApproved = await _checkProfessionalApproval(userId);
        if (isApproved) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DoctorHomePage()));
        } else {
          _showSnackBar("Your account is not approved yet. Please contact support.");
        }
      } else {
        _showSnackBar("Unknown role. Please contact support.");
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Login failed. Please try again.");
    } catch (e) {
      _showSnackBar("An unexpected error occurred.");
    }
  }

  // ✅ Fetch role from Firestore
  Future<String?> _fetchUserRole(String userId) async {
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data()?['role'];
    }

    DocumentSnapshot<Map<String, dynamic>> sellerDoc =
        await FirebaseFirestore.instance.collection('sellers').doc(userId).get();
    if (sellerDoc.exists) {
      return "seller";
    }

    DocumentSnapshot<Map<String, dynamic>> professionalDoc =
        await FirebaseFirestore.instance.collection('professionals').doc(userId).get();
    if (professionalDoc.exists) {
      return "professional";
    }

    return null;
  }

  // ✅ Check if professional is approved
  Future<bool> _checkProfessionalApproval(String professionalId) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection('professionals').doc(professionalId).get();
    return doc.exists ? (doc.data() != null ? doc.data()!['approved'] : false) : false;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Login", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.lightBlue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(height: 120),
                _buildTextField(_emailController, 'Email Address', 'Enter your email', Icons.email),
                SizedBox(height: 16),
                _buildPasswordField(),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _loginUser,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 80.0),
                    backgroundColor: Colors.deepOrangeAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                    elevation: 5,
                  ),
                  child: Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen())),
                  child: Text("Forgot Password?", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hintText, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepOrange),
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock, color: Colors.deepOrange),
        labelText: 'Password',
        hintText: 'Enter your password',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.deepOrange),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
      ),
    );
  }
}
