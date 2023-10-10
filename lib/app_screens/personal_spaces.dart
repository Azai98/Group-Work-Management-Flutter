import 'package:collab/app_screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:collab/personal_spaces/personal_dashboard.dart';

class PersonalSpaces extends StatefulWidget{
  const PersonalSpaces({Key? key}) : super(key: key);

  @override
  _PersonalSpacesState createState() => _PersonalSpacesState();
}

class _PersonalSpacesState extends State<PersonalSpaces>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      extendBodyBehindAppBar: true,
        appBar : AppBar(
          centerTitle: true,
          title : const Text("User Space", style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.account_circle_rounded),
              highlightColor: Colors.lightBlueAccent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => profilePage()),
                );
              },
            ),
          ],
        ),
        body : personalDashboard(),
    );
  }
}