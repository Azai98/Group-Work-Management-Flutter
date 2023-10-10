import 'package:collab/initial_components/rounded_name_field.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collab/initial_screens/Login/login_screen.dart';
import 'package:collab/initial_screens/Signup/components/background.dart';
import 'package:collab/initial_screens/Signup/components/or_divider.dart';
import 'package:collab/initial_components/already_have_an_account_acheck.dart';
import 'package:collab/initial_components/rounded_button.dart';
import 'package:collab/initial_components/rounded_input_field.dart';
import 'package:collab/initial_components/rounded_password_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:collab/widgets/provider_widgets.dart';


class SignupBody extends StatefulWidget{
  const SignupBody({Key? key}) : super(key: key);

  @override
  _SignupBody createState() => _SignupBody();
}


class _SignupBody extends State<SignupBody> {
  final _formKey = GlobalKey<FormState>();
  String error = '';

  // text field state
  String email = '';
  String password = '';
  String name = '';

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
               margin: EdgeInsets.only(top: 70, right: 235),
               child: Text(
              "SIGNUP",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, fontFamily: 'Raleway'),
              ),
             ),
            SizedBox(height: size.height * 0.03),
            SizedBox(height: size.height * 0.03),
            RoundedInputField(
              onChanged: (value) {
                setState(() {
                  email = value.trim();
                });
              },
            ),
            SizedBox(height: size.height * 0.03),
            RoundedNameField(
              onChanged: (value) {
                setState(() {
                  name = value.trim();
                });
              },
            ),
            SizedBox(height: size.height * 0.03),
            RoundedPasswordField(
              onChanged: (value) {
                setState(() {
                  password = value.trim();
                });
              },
            ),
            SizedBox(height: size.height * 0.05),
            RoundedButton(
              text: "SIGNUP",
                press: () async {
                  if (_formKey.currentState!.validate() &&
                      EmailValidator.validate(email.trim())) {
                    final result = await
                        auth
                        .signUp(
                      email: email.trim(),
                      password: password.trim(),
                      name: name.trim(),
                    );
                    if (result == "Signed up") {
                      _showDialog(context);
                    }
                  }
                },
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
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
                  label:Text('Sign Up with Google'),
                  onPressed: () async {
                    setState(() {
                    });

                    User? user =
                    await auth.signInWithGoogle(context: context);

                    setState(() {
                    });

                    if(user != null){
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Successfully sign-up!'),
                            action: SnackBarAction(
                              label: 'Login now!',
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return LoginScreen();
                                    },
                                  ),
                                );
                              },
                            ),
                          )
                      );
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    )
        )
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert!!"),
          content: Text("Account created successfully."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

}



