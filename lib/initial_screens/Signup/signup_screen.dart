import 'package:flutter/material.dart';
import 'package:collab/initial_screens/Signup/components/body.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignupBody(),
    );
  }
}
