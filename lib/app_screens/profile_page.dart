import 'package:collab/auth_service.dart';
import 'package:collab/initial_screens/Welcome/welcome_screen.dart';
import 'package:collab/profile_screens/pages/profile_page.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class profilePage extends StatefulWidget{
  const profilePage({Key? key}) : super(key: key);

  @override
  _profilePage createState() => _profilePage();
}

// ignore: camel_case_types
class _profilePage extends State<profilePage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text("User Profile", style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.logout, color: Colors.white),
            label: Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: (){
              AuthService.logout();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => WelcomeScreen()),
                  ModalRoute.withName('/')
              );
            },
          )
        ]

      ),
      body: Stack(children: [
        Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/profilepage-ui.webp'),
                    fit: BoxFit.cover))),
        Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.7)
                ]))),
        SafeArea(child: ProfileView())
      ])
    );

  }
}
