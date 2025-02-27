import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:womenconnect/admin/admin%20forgotpage.dart';
import 'package:womenconnect/admin/admin%20login.dart';
import 'package:womenconnect/firebase_options.dart';
import 'package:womenconnect/professional/profesional%20login.dart';
import 'package:womenconnect/professional/professional%20forgotpage.dart';
import 'package:womenconnect/professional/professional%20signup%20screen.dart' as professional_signup;
import 'package:womenconnect/user/buyproduct.dart';
import 'package:womenconnect/user/userhomepage.dart' as user_homepage;
import 'package:womenconnect/user/addproducts.dart';
import 'package:womenconnect/user/bookappointment.dart';
import 'package:womenconnect/user/choosescreen.dart';
import 'package:womenconnect/user/edit%20userprofile.dart';
import 'package:womenconnect/user/forgotpage.dart';
import 'package:womenconnect/user/user%20login.dart';
import 'package:womenconnect/user/user%20profile.dart';
import 'package:womenconnect/user/user%20signup%20screen.dart';
import 'package:womenconnect/user/viewproducts.dart';

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
      home:UserLoginScreen(),
    );
  }
}


