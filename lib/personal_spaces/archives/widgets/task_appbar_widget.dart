import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/project_screens/project_details.dart';
import 'package:collab/search_appbar_page.dart';
import 'package:collab/widgets/provider_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

AppBar buildAppBar(BuildContext context, String projectID, String taskID, bool status, String completedTime) {
  return AppBar(
    iconTheme: IconThemeData(
        color: Colors
            .black), // set backbutton color here which will reflect in all screens.
    leading: BackButton(),
    backgroundColor: Colors.transparent,
    elevation: 0,
    actions: [
      Row(children: [
        Theme(data: Theme.of(context).copyWith(
            dividerColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black)
        ),
            child: status==false?
            TextButton.icon(onPressed: (){showCompleteDialog(context, projectID, taskID); }, icon: Icon(Icons.done_rounded), label: Text('Complete'))
                :RichText(text: TextSpan( children: [TextSpan(text: "Completed on: " + completedTime,style: TextStyle(color: Colors.green, fontSize: 13)),
              WidgetSpan(child: Icon(Icons.done_sharp, color: Colors.green,),)],),)
        ),
        Theme(data: Theme.of(context).copyWith(
            dividerColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black)
        ),
          //list if widget in appbar actions
          child:PopupMenuButton<int>(//don't specify icon if you want 3 dot menu
            color: Colors.blue,
            onSelected: (item) => onClicked(context, item, projectID, taskID),
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: const [
                    Icon(Icons.delete, color: Colors.black),
                    SizedBox(width: 8),
                    Text("Delete task",style: TextStyle(color: Colors.black, fontFamily: 'Raleway'),),
                  ],
                ),
              ),
            ],
          ),),
      ],
      ),
    ],
  );
}

void onClicked(BuildContext context, int item, projectID, taskID){
  int count = 0;
  List<Map<String, dynamic>> membersList = [];

  getCurrentMembers() async {
    FirebaseFirestore db = FirebaseFirestore.instance; FirebaseAuth auth = FirebaseAuth.instance;

    await db
        .collection('projects_logDB')
        .doc(auth.currentUser!.uid)
        .collection('project_archive')
        .doc(projectID)
        .get()
        .then((value) {
        for(int i = 0; i<value.data()?["members"].length ; i++) {
          membersList.add({
            "username": value.data()!["members"][i]["username"].toString(),
            "email": value.data()!["members"][i]["email"].toString(),
            "uid": value.data()!["members"][i]["uid"].toString(),
          });
        }
    });
  }

  Future removeTask() async{
    await getCurrentMembers();
    final db = FirebaseFirestore.instance;
    //execute
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
  }

  deleteConfirmation(BuildContext context) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
      child: Text("Yes"),
      onPressed:  () async{
        try{
          await removeTask();
        }catch(e){
          print(e);
        }
        Future.delayed(Duration.zero, () {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Task successfully removed!'),));
          Navigator.popUntil(context, (route) {
            return count++ == 2;
          });
        });
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
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  switch(item){
    case 0 :
      deleteConfirmation(context);
      break;
  }
}

showCompleteDialog(BuildContext context, projectID, taskID) {
  DateTime time = DateTime.now();
  List<Map<String, dynamic>> membersList = [];
  final db = Provider.of(context)!.db;
  getCurrentMembers() async {
    FirebaseFirestore db = FirebaseFirestore.instance; FirebaseAuth auth = FirebaseAuth.instance;
    await db
        .collection('projects_logDB')
        .doc(auth.currentUser!.uid)
        .collection('project_archive')
        .doc(projectID)
        .get()
        .then((value) {
      for(int i = 0; i<value.data()?["members"].length ; i++) {
        membersList.add({
          "username": value.data()!["members"][i]["username"].toString(),
          "email": value.data()!["members"][i]["email"].toString(),
          "uid": value.data()!["members"][i]["uid"].toString(),
        });
      }
    });
  }
  // set up the buttons
  Widget cancelButton = ElevatedButton(
    child: Text("Cancel"),
    onPressed:  () {
      Navigator.pop(context);
    },
  );
  Widget continueButton = ElevatedButton(
    child: Text("Yes"),
    onPressed:  () async {
      try{
        await getCurrentMembers();

        for(int i = 0; i<membersList.length ; i++) {
          final uid = membersList[i]['uid'];
          await db.collection('projects_logDB')
              .doc(uid)
              .collection('project_archive')
              .doc(projectID)
              .collection('task_archive')
              .doc(taskID)
              .update(setCompleted(true, time));
        }
        Navigator.pop(context);
      }catch(e){
        print(e);
      }

      Future.delayed(Duration.zero, () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Task completed!'),));
      });
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("AlertDialog"),
    content: Text("Are you sure to set the task as completed?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Map<String, dynamic> setCompleted(final status, DateTime time) => {
  'complete': status,
  'completeTime': time,
};

