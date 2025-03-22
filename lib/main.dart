import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:womenconnect/admin/adminhome.dart';
import 'package:womenconnect/admin/manageprofessionals.dart';
import 'package:womenconnect/admin/managesellers.dart';
import 'package:womenconnect/admin/userlistscreen.dart';
import 'package:womenconnect/admin/viewproduct.dart';
import 'package:womenconnect/firebase_options.dart';
import 'package:womenconnect/professional/professional%20signup%20screen.dart' as professional_signup;
import 'package:womenconnect/professional/professional%20signup%20screen.dart';
import 'package:womenconnect/professional/professionals_profile.dart';
import 'package:womenconnect/seller/addproduct.dart';
import 'package:womenconnect/seller/seller%20homepage.dart';
import 'package:womenconnect/seller/seller%20signup%20screen.dart';
import 'package:womenconnect/seller/sellerprofile.dart';
import 'package:womenconnect/seller/vieworder.dart';
import 'package:womenconnect/splashscreen.dart';
import 'package:womenconnect/user/buyproduct.dart';
import 'package:womenconnect/user/homescreen.dart';
import 'package:womenconnect/user/userhomepage.dart' as user_homepage;
import 'package:womenconnect/user/bookappointment.dart';
import 'package:womenconnect/user/choosescreen.dart';
import 'package:womenconnect/user/edit%20userprofile.dart';
import 'package:womenconnect/user/forgotpassword_screen.dart';
import 'package:womenconnect/user/login_screen.dart';
import 'package:womenconnect/user/user%20profile.dart';
import 'package:womenconnect/user/user%20signup%20screen.dart';
import 'package:womenconnect/user/viewproducts.dart';
import 'package:womenconnect/splashscreen.dart';
import 'professional/professional homepage.dart';


void main()async
 {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  SplashScreen(),
    );
  }
}


