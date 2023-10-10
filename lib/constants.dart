import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const kPrimaryColor = Colors.deepOrangeAccent;
const kPrimaryLightColor = Colors.orangeAccent;
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

String getPath(){
  String uid = (_firebaseAuth.currentUser!).uid;
  return uid;
}