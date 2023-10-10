import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/database.dart';
import 'package:collab/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

//Email Login
class AuthService {

  // 1  --Variable--
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final GoogleSignIn googleSignIn = GoogleSignIn();

  // 2
  Stream<String?> get onAuthStateChanged =>
      _firebaseAuth.authStateChanges().map((User? user) => user?.uid);

  String getCurrentUID() {
    return (_firebaseAuth.currentUser!).uid;
  }

  // GET CURRENT USER
  Future getCurrentUser() async {
    return _firebaseAuth.currentUser!;
  }


  // 3
  Future<User?> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(e) {
      print(e.message);
    }
  }

  // 4
  Future<String?> signUp({required String email, required String password, required String name}) async {
    try {
      bool isRegister = await isEmailRegistered(email);
      if(isRegister == true) {
        UserCredential result = await _firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password);
        _firebaseAuth.currentUser!.updateDisplayName(name);
        User? user = result.user;
        await DatabaseService(uid: user!.uid).updateUserData(
            name, '01x-xxxxxxx', 'Edit yourself now!', email, user.uid);
        return "Signed up";
      }
      else{
        Fluttertoast.showToast(
          backgroundColor: Colors.grey,
          msg: "The email is registered, please use another email.",
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,
        );
      }
    } on FirebaseAuthException catch(e) {
      return e.message;
    }
  }

  Future<bool> isEmailRegistered(String email) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users_data')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.length > 0) {
      return false;
    } else
      print('Email validated and can be used');
      return true;
  }

  // 5
  Future<String?> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return "Signed out";
    } on FirebaseAuthException catch(e) {
      return e.message;
    }
  }

// 6
  User? getUser() {
    try {
      return _firebaseAuth.currentUser;
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignInAccount? googleSignInAccount =
    await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {

        final UserCredential userCredential =
        await auth.signInWithCredential(credential);
        user = userCredential.user;

        //get user data from firestore
        final snapShot = await FirebaseFirestore.instance
            .collection('users_data')
            .doc(user!.uid) // varuId in your case
            .get();

        // ignore: unnecessary_null_comparison
        if (snapShot == null || !snapShot.exists) {
          // Document with id == varuId doesn't exist.
          await DatabaseService(uid: user.uid).updateUserData(user.displayName!, '01x-xxxxxxx', 'Edit yourself now!', user.email!, user.uid);
          // You can add data to Firebase Firestore here
        }

      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            AuthService.customSnackBar(
              content:
              'The account already exists with a different credential.',
            ),
          );
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            AuthService.customSnackBar(
              content:
              'Error occurred while accessing credentials. Try again.',
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          AuthService.customSnackBar(
            content: 'Error occurred using Google Sign-In. Try again.',
          ),
        );
      }
      return user;
    }
  }

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: const TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  static Future<FirebaseApp> initializeFirebase({
    required BuildContext context,
  }) async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const bottomNavigationBar(
          ),
        ),
      );
    }

    return firebaseApp;
  }

  static Future<void> logout() async {
      if(googleSignIn.currentUser != null) {
        _firebaseAuth.signOut();
        await googleSignIn.disconnect();
      }
      else {
        _firebaseAuth.signOut();
      }
  }

}

