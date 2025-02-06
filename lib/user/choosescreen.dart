import 'package:flutter/material.dart';
import 'package:womenconnect/admin/admin%20login.dart';
import 'package:womenconnect/professional/profesional%20login.dart';
import 'package:womenconnect/user/user%20login.dart';

class ChooseScreen extends StatefulWidget {
  const ChooseScreen({super.key});

  @override
  State<ChooseScreen> createState() => _ChooseScreenState();
}

class _ChooseScreenState extends State<ChooseScreen> {
  String? selectedRole; // Variable to store the selected role

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 17, 203, 39), Color.fromARGB(255, 37, 252, 127)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Choose Your Role",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                _buildRoleButton("Admin", Icons.admin_panel_settings),
                _buildRoleButton("User", Icons.person),
                _buildRoleButton("Professional", Icons.business_center),
                _buildRoleButton("Officer", Icons.security),

                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: selectedRole != null
                      ? () {if(selectedRole=="User")
            {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserLoginScreen(),));
            }
            else if(selectedRole=="Admin")
            {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AdminLoginScreen(),));
            }
              else if(selectedRole=="Professional")
            {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfessionalLoginScreen(),));
            }
                            // Ha
                          //
                          //ndle continue action
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Proceeding as $selectedRole')),
                          );
                          // Navigate based on role (You can add your navigation logic here)
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

  Widget _buildRoleButton(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            
            selectedRole = title; // Update selected role
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedRole == title
              ? Colors.orangeAccent // Highlight selected role
              : const Color.fromARGB(255, 255, 210, 68),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
