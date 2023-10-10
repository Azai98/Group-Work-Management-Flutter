// ignore_for_file: implementation_imports
import 'package:collab/authenticate_page.dart';
import 'package:collab/initial_screens/Signup/components/or_divider.dart';
import 'package:collab/main.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:collab/initial_screens/Login/components/background.dart';
import 'package:collab/initial_screens/Signup/signup_screen.dart';
import 'package:collab/initial_components/already_have_an_account_acheck.dart';
import 'package:collab/initial_components/rounded_button.dart';
import 'package:collab/initial_components/rounded_input_field.dart';
import 'package:collab/initial_components/rounded_password_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:collab/widgets/provider_widgets.dart';

class LoginBody extends StatefulWidget{
  const LoginBody({Key? key}) : super(key: key);

  @override
  _LoginBody createState() => _LoginBody();
}

class _LoginBody extends State<LoginBody> {
  final _formKey = GlobalKey<FormState>();
  String _email = "", _password = "";


  @override
  Widget build(BuildContext context) {
    final auth = Provider.of(context)!.auth;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
    body: Form(
        key: _formKey,
        child:Background(
        child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 120, right: 250),
              child:Text(
              "LOGIN",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, fontFamily: 'Raleway'),
            ),
            ),
            SizedBox(height: size.height * 0.03),

            SizedBox(height: size.height * 0.03),
            RoundedInputField(
              onChanged: (value) {
                setState(() {
                  _email = value.trim();
                });
              },
            ),
            SizedBox(height: size.height * 0.03),
            RoundedPasswordField(
              onChanged: (value) {
                setState(() {
                  _password = value.trim();
                });
              },
            ),
            SizedBox(height: size.height * 0.05),
            RoundedButton(
              text: "LOGIN",
              press: () async{
                setState(() {
                });
                if (_formKey.currentState!.validate() &&
                EmailValidator.validate(
                _email.trim())) {
                  try {
                    final user = await auth.signIn(
                        email: _email, password: _password);
                    if (auth.getCurrentUID().isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Login Successful'),));
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => bottomNavigationBar(),
                          ),
                        );
                    }
                  } catch(e){
                    Fluttertoast.showToast(
                      backgroundColor: Colors.grey,
                      msg: "Login failed, password or username does not match",
                      gravity: ToastGravity.CENTER,
                      fontSize: 16.0,
                    );
                  }
                }
              },
            ),
            OrDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton.icon(
                  style:ElevatedButton.styleFrom(
                    primary:Colors.white,
                    onPrimary: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Raleway'),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide(width: 0.7, color: Colors.deepOrangeAccent),
                    shadowColor: Colors.deepOrangeAccent,
                  ),
                  icon: FaIcon(FontAwesomeIcons.google, color: Colors.red,),
                  label:Text('Sign In with Google'),
                  onPressed: () async {
                    setState(() {
                    });

                    User? user =
                    await auth.signInWithGoogle(context: context);

                    setState(() {
                    });

                    if (user != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Login Successful'),));
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => bottomNavigationBar(),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),

            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SignUpScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
    ),
    )
    )
    );
  }
}





