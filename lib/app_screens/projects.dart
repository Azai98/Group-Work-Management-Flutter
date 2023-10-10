import 'package:collab/app_screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:collab/project_screens/project_view.dart';

class Projects extends StatefulWidget{
  const Projects({Key? key}) : super(key: key);

  @override
  _ProjectsState createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar : AppBar(
          centerTitle: true,
          title : const Text("Work Space", style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
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
        body : Projectview(),
    );
  }
}