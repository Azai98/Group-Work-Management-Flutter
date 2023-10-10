import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:collab/widgets/provider_widgets.dart';
import 'add_project.dart';
import 'project_details.dart';

class CollaboratorList extends StatefulWidget {
  final String projectID;
  const CollaboratorList({Key? key, required this.projectID}) : super(key: key);


  @override
  _CollaboratorList createState() => _CollaboratorList();
}

class _CollaboratorList extends State<CollaboratorList> {
  List<Map<String, dynamic>> membersList = [];

  @override
  void initState() {
    super.initState();
    getCurrentMembers();
  }

  void getCurrentMembers() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    await db
        .collection('projects')
        .doc(widget.projectID)
        .get()
        .then((value) {
      setState(() {
        for(int i = 0; i<value.data()?["members"].length ; i++) {
          membersList.add({
            "username": value.data()!["members"][i]["username"].toString(),
            "email": value.data()!["members"][i]["email"].toString(),
            "uid": value.data()!["members"][i]["uid"].toString(),
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of(context)!.auth;
    final db = Provider.of(context)!.db;
    return Scaffold(
      appBar : AppBar(
        centerTitle: true,
        title: const Text(
          "Collaborator List",
          style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,

      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/workspaces-ui.webp'),
                fit: BoxFit.cover)),
        child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [
                Colors.black.withOpacity(0.8),
                Colors.black.withOpacity(0.7)
              ])),
          padding: EdgeInsets.all(10),
          height: MediaQuery.of(context).size.height,
          child: ListView.builder(
          itemCount: membersList.length,
          itemBuilder: (BuildContext context, int index) {
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users_data')
                  .doc(membersList[index]['uid'])
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text('User not found');
                }

                Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;

                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.lightBlue),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                    ),
                    title: Text(
                      membersList[index]['username'],
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        Text(
                          'Email: ${membersList[index]['email']}',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Phone: ${userData['phone']}',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        userData['bio'] == 'Edit yourself now!' ?
                        Text(
                          'Bio: No bio',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ):
                        Text(
                          'Bio: ${userData['bio']}',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      )     // color: Colors.red,
        ),
    );
  }
}
