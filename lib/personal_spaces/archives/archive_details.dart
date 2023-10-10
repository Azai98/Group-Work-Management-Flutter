import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/constants.dart';
import 'package:collab/personal_spaces/archives/widgets/dismissible_widget.dart';
import 'package:collab/personal_spaces/archives/archive_task_details.dart';
import 'package:collab/widgets/provider_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collab/personal_spaces/archives/widgets/project_appbar_widget.dart';
import 'package:intl/intl.dart';

// ignore: camel_case_types
class archiveDetails extends StatefulWidget {
  final String projectID;
  const archiveDetails({Key? key, required this.projectID}) : super(key: key);

  @override
  _archiveDetails createState() => _archiveDetails();
}

// ignore: camel_case_types
class _archiveDetails extends State<archiveDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String title = '', description = '';
  List<Map<String, dynamic>> membersList = [];

  @override
  void initState() {
    super.initState();
    getArchivedDetails();
    getCurrentMembers();
  }

  void getArchivedDetails() async {
    FirebaseFirestore db = FirebaseFirestore.instance; FirebaseAuth auth = FirebaseAuth.instance;

    await db
        .collection('projects_logDB')
        .doc(auth.currentUser!.uid)
        .collection('project_archive')
        .doc(widget.projectID)
        .get()
        .then((value) {
      setState(() {
        title = value['title'];
        description = value['description'];
      });
    });
  }

  void getCurrentMembers() async {
    FirebaseFirestore db = FirebaseFirestore.instance; FirebaseAuth auth = FirebaseAuth.instance;

    await db
        .collection('projects_logDB')
        .doc(auth.currentUser!.uid)
        .collection('project_archive')
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
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white70.withOpacity(0.93),
      appBar: buildAppBar(context, title, description, widget.projectID, membersList),
      body: Stack(
          children:<Widget>[
            Container(
            decoration: BoxDecoration(
            image: DecorationImage(
            image: AssetImage('assets/images/archive-ui1.webp'),
            fit: BoxFit.cover)),
          ),
        SingleChildScrollView(
        child : SafeArea(
          child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              height: 60,
              decoration: BoxDecoration(
                  border:Border(bottom: BorderSide (color: Colors.blueGrey))),
              width: width,
              child:Row( children:[
                StreamBuilder<QuerySnapshot>(
                    stream: db
                        .collection('projects_logDB')
                        .doc(auth.getCurrentUID())
                        .collection('project_archive')
                        .doc(widget.projectID)
                        .collection('task_archive')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        var docs = snapshot.data!.docs;
                        int totalTask = docs.length;
                        int toDo = 0; int done = 0;
                        for(int i = 0; i<docs.length; i ++){
                          if(docs[i]['complete'] == true){
                            done++;
                          }
                          else{
                            toDo++;
                          }
                        }
                        return Flexible(
                            child:Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children:[
                                  Align(
                                    child:
                                      Text('Total Tasks: ' + totalTask.toString(), style: TextStyle(color: Colors.white, fontFamily: 'Raleway', fontWeight: FontWeight.bold, fontSize: 18)),
                                    ),
                                  Align(
                                      child:RichText(text: TextSpan( children: [
                                        TextSpan(text: 'Incomplete: ' + toDo.toString() + '\t\t',style: TextStyle(color: Colors.white, fontFamily: 'Raleway', fontWeight: FontWeight.bold, fontSize: 18)),
                                        TextSpan(text: 'Done: ' + done.toString(),style: TextStyle(color: Colors.white,  fontFamily: 'Raleway', fontWeight: FontWeight.bold, fontSize: 18)),],),)
                                  )]));
                      }}),
              ]
              ),
            ),
           StreamBuilder<QuerySnapshot>(
                stream: db
                    .collection('projects_logDB')
                    .doc(auth.getCurrentUID())
                    .collection('project_archive')
                    .doc(widget.projectID)
                    .collection('task_archive')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                        height: MediaQuery.of(context).size.height *0.7,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator()
                    );
                  } else {
                    var docs = snapshot.data!.docs;
                    if(docs.isEmpty){
                      return Container(
                          height: MediaQuery.of(context).size.height *0.7,
                          alignment: Alignment.center,
                          child:Text("No tasks in this project now.",
                            style: TextStyle( color: Colors.white, fontFamily: 'Raleway', fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,)
                      );
                    }
                    else {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: docs.length + 1,
                        separatorBuilder: (context, index) =>
                            Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                        color: Colors.white,
                                        width: 0.5,
                                      ))),),
                        itemBuilder: (context, index) {
                          if (index == docs.length) {
                            return Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.white,
                                          width: 0.0
                                      ))),);
                          }
                          DateTime due = DateTime.parse(
                              docs[index]['due_date']);
                          DateTime completedTime = DateTime.parse(
                              docs[index]['completeTime'].toDate().toString());

                          return DismissibleWidget(
                            item: docs,
                            child: buildListTile(
                                docs, index, due, completedTime),
                            onDismissed: (direction) =>
                                dismissItem(
                                    context, index, direction, docs[index].id),
                          );
                        },
                      );
                    }
                  }
                },
              ),
          ],
        ),
      ),)])
    );
  }

  Widget buildListTile(final docs, int index, DateTime due, DateTime completedTime) => InkWell(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => archiveTaskDetails(
                title: docs[index]['task_name'],
                description: docs[index]['task_desc'],
                projectID: widget.projectID,
                taskID: docs[index].id,
              )));
    },
    child: Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Center(
              child: Text(
                docs[index]['task_name'][0],
                style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 25
                ),
              ),
            ),
            height: 60,
            width: 60,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white70
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  docs[index]['complete'] == false ? Text('Task: ' +
                    docs[index]['task_name'],
                    style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                  ):
                  Text('Task: ' +
                    docs[index]['task_name'],
                    style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w500, decoration: TextDecoration.lineThrough, color: Colors.white),
                  ),

                  docs[index]['complete'] == false ? Text('Details: ' +
                    docs[index]['task_desc'],
                    maxLines: 2, style: GoogleFonts.roboto(fontSize: 15, color: Colors.white),
                  ):
                  Text('Details: ' +
                    docs[index]['task_desc'],
                    maxLines: 2, style: GoogleFonts.roboto(fontSize: 15,decoration: TextDecoration.lineThrough, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Assigned to: ' + docs[index]['assignee_name'],
                    style: GoogleFonts.roboto(
                      fontSize: 15, color: Colors.white
                    ),
                  ),
                  Text(
                    docs[index]['complete']==true?"Completed on: " + DateFormat.yMd().add_jm().format(completedTime) : "Due on : " + DateFormat.yMd().add_jm().format(due),
                    style: GoogleFonts.roboto(
                        fontSize: 15,
                        color: docs[index]['complete'] == true?Colors.green : Colors.red,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  void dismissItem(BuildContext context, int index, DismissDirection direction, String taskID) {
    switch (direction) {
      case DismissDirection.startToEnd: //1 -- only allow to be deleted since it was archived
        try {
          deleteConfirmation(context, widget.projectID, taskID);
        }catch(e){
          print(e);
        }
        break;

      case DismissDirection.endToStart: //1 -- only allow to be deleted since it was archived
        try {
          deleteConfirmation(context, widget.projectID, taskID);
        }catch(e){
          print(e);
        }
        break;
      default:
        break;
    }
  }

  deleteConfirmation(BuildContext context, projectID, taskID) {
    final db = Provider.of(context)!.db;
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text("Cancel"),
      onPressed:  () {
        setState(() {
          Navigator.pop(context);
        });
      },
    );
    Widget continueButton = ElevatedButton(
      child: Text("Yes"),
      onPressed:  () async{
        try{
          Future.delayed(Duration.zero, () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Task successfully deleted!'),));
          });
          //delete task from eventDB on every user that terlibat in project
          for(int i = 0; i<membersList.length ; i++) {
            final uid = membersList[i]['uid'];
            await db
                .collection('projects_logDB')
                .doc(uid)
                .collection('project_archive')
                .doc(projectID)
                .collection('task_archive')
                .doc(taskID)
                .delete();
          }
        }catch(e){
          print(e);
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete Confirmation"),
      content: Text("Are you sure to delete this task?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
