import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Screens/home_screen.dart';
import 'Screens/sign_in_screen.dart';
import 'theme.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool i = false;
  String social="";

  Future<void> isUserLogin() async {


   // await Firebase.initializeApp();
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    User user = await firebaseAuth.currentUser;


    if(user == null){
      setState(() {
        i= false;
      });
    }
    else{

      setState(() {

        social = user.providerData[0].providerId;
        i= true;
      });
    }

  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {

      await isUserLogin();

    });
    super.initState();

    print(i);
  }

  @override
  Widget build(BuildContext context) {

    Timer(
        Duration(milliseconds: 6000),
            () =>
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => CircularProgressIndicator())));


    return MaterialApp(
      theme: theme(),
      debugShowCheckedModeBanner: false,
      home: i?HomeScreen(text: social,):SignInScreen(),
    );
  }
}

