import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:womenconnect/user/choosescreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _navigateToChooseScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ChooseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Center(
        child: Lottie.asset(
          'assets/Animation - 1741582536019.json',
          width: 250,
          height: 250,
          fit: BoxFit.contain,
          onLoaded: (composition) {
            Future.delayed(composition.duration, _navigateToChooseScreen);
          },
        ),
      ),
    );
  }
}
