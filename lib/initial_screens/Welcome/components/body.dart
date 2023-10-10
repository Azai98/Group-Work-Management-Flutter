import 'package:flutter/material.dart';
import 'package:collab/initial_screens/Login/login_screen.dart';
import 'package:collab/initial_screens/Signup/signup_screen.dart';
import 'package:collab/initial_screens/Welcome/components/background.dart';
import 'package:collab/initial_components/rounded_button.dart';

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // This size provide us total height and width of our screen
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: size.height * 0.08),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right:185),
            child: const Text(
              "Group Work",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, fontFamily: 'Raleway', color: Colors.white, shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.blueAccent,
                  offset: Offset(3.0, 3.0),
                ),
              ],
              ),
            ),
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left:85),
              child : const Text("Management Apps",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Raleway', color: Colors.white)),
            ),
            SizedBox(height: size.height * 0.07),
            Image.asset(
              "assets/icons/icon1.png",
              height: size.height * 0.30,
            ),
            SizedBox(height: size.height * 0.03),
            RoundedButton(
              text: "LOGIN",
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
            RoundedButton(
              text: "SIGN UP",
              textColor: Colors.white,
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
            SizedBox(height: size.height * 0.05),
            Container(
              alignment: Alignment.center,
              child : const Text("Developed by Azaiman (FYP 2)",style: TextStyle(fontSize: 15, color: Colors.blueGrey)),
            ),
          ],
        ),
      ),
    );
  }
}
