import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../constants.dart';
import '../form_error.dart';
import '../size_config.dart';
import '../social_card.dart';
import 'home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:fluttertoast/fluttertoast.dart';


class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  final _formKey = GlobalKey<FormState>();
  final List<String> errors = [];
  String phone;
  String password;
  bool remember = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
    FacebookLogin facebookLogin = FacebookLogin();


  void addError({String error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error);
      });
  }

  void removeError({String error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  _signInWithGoogle(BuildContext context) async{
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken,accessToken: googleAuth.accessToken);

    final User user = (await firebaseAuth.signInWithCredential(credential)).user;

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(text: 'google.com',)));


  }

  void getData(String phone, String password){
    final userRef = FirebaseFirestore.instance.collection('signin');
    userRef.get().then((snapshot) {
      snapshot.docs.forEach((doc) {

        if(doc.data()['phone'] == phone && doc.data()['password'] == password)
          {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(text: 'phone',)));
          }
        else{
          Fluttertoast.showToast(
              msg: "Invalid phone number or password",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
          print("invalid");
        }
      });
    });

  }

  Future<void> handleLogin() async {

    final FacebookLoginResult result = await facebookLogin.logIn(['email']);


    switch (result.status) {
      case FacebookLoginStatus.cancelledByUser:
        break;
      case FacebookLoginStatus.error:
        print(result.errorMessage);
        break;
      case FacebookLoginStatus.loggedIn:
        try {
          print("in try");
          await loginWithfacebook(result);

         // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(text: 'facebook',)));
        } catch (e) {
          print(e);
        }
        break;
    }
  }

  Future loginWithfacebook(FacebookLoginResult result) async {

    final FacebookAccessToken accessToken = result.accessToken;
    AuthCredential credential =
    FacebookAuthProvider.credential(accessToken.token);
    User user = (await _auth.signInWithCredential(credential)).user;

    if(user != null){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(text: 'facebook.com',))).then((value) {
        print("Navigated");
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle:true,
        title: Text("Sign In",),
      ),
      body: SafeArea(
          child: Container(
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: SizeConfig.screenHeight * 0.04,),
                      Text("Welcome Back",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: getProportionateScreenWidth(28),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Sign in with your email and password \n or continue with social media",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.08,),
                      SignForm(),
                      SizedBox(height: SizeConfig.screenHeight * 0.08,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SocialCard(
                            icon: "assets/google-icon.svg",
                            press: (){
                             _signInWithGoogle(context);
                            },
                          ),
                          SocialCard(
                            icon: "assets/facebook-2.svg",
                            press: () async{

                              await handleLogin();
                            },
                          ),
                          SocialCard(
                            icon: "assets/twitter.svg",
                            press: () {


                            },
                          ),
                        ],
                      ),
                      SizedBox(height: getProportionateScreenHeight(20),),
                  //    NoAccountText()
                    ],
                  ),
                ),
              ),
            ),
          )
      ),
    );
  }

  Form SignForm(){
   return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmailFormField(),
          SizedBox(height: getProportionateScreenHeight(30),),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(10),),

          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(20)),

          FlatButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: kPrimaryColor,
            height: getProportionateScreenWidth(56),
            minWidth: double.infinity,
            onPressed: (){
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                // if all r valid then go to success screen

                print("success");
                  getData(phone.trim(), password.trim());
             //   loginWithEmailPassword(email.trim(), password.trim());

              }
            },
            child: Text(
              "Sign In",
              style: TextStyle(
                fontSize: getProportionateScreenWidth(18),
                color: Colors.white,
              ),
            ),
          ),

        ],
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.phone,
      onSaved: (newValue) => phone = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPhoneNumberNullError);
        } else if (phoneValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidPhoneError);
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kPhoneNumberNullError);
          return "";
        } else if (!phoneValidatorRegExp.hasMatch(value)) {
          addError(error: kInvalidPhoneError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Phone",
        hintText: "Enter your phone number",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: Icon(Icons.phone),
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if (value.length < 8) {
          addError(error: kShortPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Enter your password",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: Icon(Icons.lock_rounded),
      ),
    );
  }
}
