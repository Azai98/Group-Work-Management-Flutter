import 'package:collab/initial_screens/Welcome/welcome_screen.dart';
import 'package:collab/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticatePage extends StatelessWidget{
  const AuthenticatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(

    // TODO: implement build
    body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const bottomNavigationBar();
        } else if (snapshot.hasError) {
          return const Center(child: Text('Something Went Wrong!'));
        } else {
          return WelcomeScreen();
        }
      }
      ),
  );

}

// class AuthenticationWrapper extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final firebaseuser = context.watch<User>();
//     if (firebaseuser != null) {
//       return bottomNavigationBar();
//     }
//     return WelcomeScreen();
//   }
// }