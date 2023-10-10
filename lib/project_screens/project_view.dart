import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:collab/widgets/provider_widgets.dart';
import 'add_project.dart';
import 'project_details.dart';
class Projectview extends StatefulWidget {
  const Projectview({Key? key}) : super(key: key);

  @override
  _Projectview createState() => _Projectview();
}

class _Projectview extends State<Projectview> {

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of(context)!.auth;
    final db = Provider.of(context)!.db;
    return Scaffold(
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
        child: StreamBuilder<QuerySnapshot>(
          stream: db
              .collection('users_data')
              .doc(auth.getCurrentUID())
              .collection('users_project')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              var docs = snapshot.data!.docs;
              if(docs.isEmpty){
                return Center(
                  child:Text("\t\t\tYou have no projects. \nTap + to create a new one",
                            style: TextStyle(color: Colors.white, fontFamily: 'Raleway', fontSize: 20, fontWeight: FontWeight.bold),)
                );
              }
              else {
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var time = (docs[index]['timestamp'] as Timestamp).toDate();
                    DateTime start = DateTime.parse(
                        docs[index]['project start']);
                    DateTime end = DateTime.parse(docs[index]['project end']);
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    projectDetails(
                                      projectID: docs[index].id,
                                    )));
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.lightBlue)),
                        height: 110,
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 20, right: 30),
                              child: Icon(Icons.groups_rounded, size: 30,
                                  color: Colors.white),
                            ),
                            Flexible(
                            child:Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(docs[index]['title'],
                                      style:
                                      GoogleFonts.montserrat(fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white)),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text('Start: ' +
                                      DateFormat.yMd().format(start) + ' ,' + ' End: ' + DateFormat.yMd().format(end),
                                      style:
                                      GoogleFonts.roboto(
                                          fontSize: 15, color: Colors.white)),
                                  Text('Created by: ',
                                      style:
                                      GoogleFonts.roboto(
                                      fontSize: 15, color: Colors.white, decoration: TextDecoration.underline)),
                                  Text(docs[index]['project creator'], softWrap: true,
                                      style:
                                      GoogleFonts.roboto(
                                          fontSize: 15, color: Colors.greenAccent)),
                                ]),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            }
          },
        ), // color: Colors.red,
      ),),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.white.withOpacity(0.3),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AddProject()));
          }),
    );
  }
}
