// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/auth_service.dart';
import 'package:collab/initial_screens/Login/login_screen.dart';
import 'package:collab/initial_screens/Signup/signup_screen.dart';
import 'package:collab/initial_screens/Welcome/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './app_screens/home_page.dart';
import './app_screens/projects.dart';
import './app_screens/personal_spaces.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_service.dart';

import 'package:collab/widgets/provider_widgets.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(Collab());
}

class Collab extends StatelessWidget {
  const Collab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider(
      auth: AuthService(),
      db: FirebaseFirestore.instance,
      // TODO: implement build
      child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomeController(),
          routes: <String, WidgetBuilder>{
            '/home': (BuildContext context) => bottomNavigationBar(),
            '/main': (BuildContext context) => WelcomeScreen(),
            '/signin': (BuildContext context) => LoginScreen(),
            '/signup': (BuildContext context) => SignUpScreen(),
          }
      ),
    );
  }
}

class HomeController extends StatelessWidget {
  const HomeController({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of(context).auth;
    return StreamBuilder<String>(
      stream: auth.onAuthStateChanged,
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool signedIn = snapshot.hasData;
          return signedIn ? bottomNavigationBar() : WelcomeScreen();
        }
        return CircularProgressIndicator();
      },
    );
  }
}





// ignore: camel_case_types
class bottomNavigationBar extends StatefulWidget{
  const bottomNavigationBar({Key key}) : super(key: key);

  @override
  _bottomNavigationBar createState() => _bottomNavigationBar();
}

// ignore: camel_case_types
class _bottomNavigationBar extends State<bottomNavigationBar>{
  final user = FirebaseAuth.instance.currentUser;
  int _currentIndex = 0;

  final tabs = [
    const Center(child:Text('Feeds')),
    const Center(child:Text('Projects')),
    const Center(child:Text('User Spaces')),
  ];

  final List<Widget> _children = [
    const HomePage(),
    const Projects(),
    const PersonalSpaces(),
  ];

  void onTappedBar(int index){
    setState(() {
      _currentIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {

      return Scaffold(
          body: _children[_currentIndex],
          bottomNavigationBar : Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.7)
                ])),
          child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedFontSize: 16,
          unselectedFontSize: 13,
          selectedLabelStyle: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
          onTap: onTappedBar,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.add_alert_outlined),
              label: "Feeds"),

            BottomNavigationBarItem(
              icon: Icon(Icons.folder_open_rounded),
              label: "Work Space",),

            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: "User Space",),
          ],
        ),),
    );
  }
}






