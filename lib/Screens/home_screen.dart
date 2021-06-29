import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_with_social_mobile/Screens/sign_in_screen.dart';

class HomeScreen extends StatelessWidget {

  final String text;

  const HomeScreen({Key key, this.text}) : super(key: key);


  Future<void> signOut(BuildContext context) async {

    if(text == 'facebook.com'){

      FacebookLogin facebookLogin = FacebookLogin();

      await FirebaseAuth.instance.signOut().then(await (value) async {
        print("Sign Out Success");

        await  facebookLogin.logOut();
        await  FirebaseAuth.instance.signOut();
        // await googleSignIn.disconnect();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen()));
        });

      })
          .catchError((e) {
        print("Error in Sign Out:" + e.toString());
        Navigator.pop(context, false);
      });



    }
    else if(text == 'google.com'){

      final GoogleSignIn googleSignIn = GoogleSignIn();

      await FirebaseAuth.instance.signOut().then(await (value) async {
        print("Sign Out Success");

        await googleSignIn.disconnect();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen()));
        });

      })
          .catchError((e) {
        print("Error in Sign Out:" + e.toString());
        Navigator.pop(context, false);
      });

    }
    else{
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen()));
      });
    }


    }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){Navigator.pop(context);},
          icon: Icon(Icons.arrow_back_ios,
          ),
        ),
        centerTitle:true,
        title: Text("Home",),
      ),
      body: SafeArea(
          child: Container(
            color: Colors.white,
            child: Center(
              child: ElevatedButton(
                child: Text("Logout"),
                onPressed: (){
                  signOut(context);
                },
              ),
            ),
          )
      ),
    );
  }
}
