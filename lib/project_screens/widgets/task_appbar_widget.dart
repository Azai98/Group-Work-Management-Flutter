import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/project_screens/project_details.dart';
import 'package:collab/search_appbar_page.dart';
import 'package:collab/widgets/provider_widgets.dart';
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
                  Icon(Icons.search, color: Colors.black),
                  SizedBox(width: 8),
                  Text("Search",style: TextStyle(color: Colors.black, fontFamily: 'Raleway'),),
                ],
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem<int>(
              value: 1,
              child: Row(
                children: const [
                  Icon(Icons.delete, color: Colors.black),
                  SizedBox(width: 8),
                  Text("Delete task",style: TextStyle(color: Colors.black, fontFamily: 'Raleway'),),
                ],
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem<int>(
              value: 2,
              child: Row(
                children: const [
                  Icon(Icons.archive, color: Colors.black),
                  SizedBox(width: 8),
                  Text("Archive task",style: TextStyle(color: Colors.black, fontFamily: 'Raleway'),),
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

  void getCurrentMembers() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection('projects')
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
    getCurrentMembers();
    final db = FirebaseFirestore.instance;
    //execute
    await db
        .collection('projects')
        .doc(projectID)
        .collection('tasks')
        .doc(taskID)
        .delete();
    //delete task from eventDB on every user that terlibat in project
    for(int i = 0; i<membersList.length ; i++) {
      final uid = membersList[i]['uid'];
      await db.collection('users_data')
          .doc(uid)
          .collection('event_data')
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

  archiveTask(List membersList) async {

    final db = Provider.of(context)!.db;

    var time = DateTime.now();

    for(int i = 0; i<membersList.length ; i++) {
      final uid = membersList[i]['uid'];
      var oldCollection = db.collection('users_data').doc(uid).collection('event_data').doc(taskID);
      var newCollection = db.collection('projects_logDB').doc(uid).collection('project_archive').doc(projectID).collection('task_archive').doc(oldCollection.id);

      DocumentSnapshot snapshot = await oldCollection.get().then((docSnapshot){
      if (docSnapshot.exists) {
        // document id does exist
        print('Successfully found document');
        newCollection
            .set({
          'assignee_email': docSnapshot['assignee_email'],
          'assignee_name': docSnapshot['assignee_name'],
          'complete': docSnapshot['complete'],
          'due_date': docSnapshot['due_date'],
          'task_desc': docSnapshot['task_desc'],
          'task_name': docSnapshot['task_name'],
          'time':  'archived on: ' + time.toString(),
          'completeTime':  time,
        })
            .then((value) => print("document moved to different collection"))
            .catchError((error) => print("Failed to move document: $error")).then((value) => ({

          oldCollection
              .delete()
              .then((value) => print("document removed from old collection"))
              .catchError((error) {
            newCollection.delete();
            print("Failed to delete document: $error");

          })
        }));
      } else {
        //document id doesnt exist
        print('Failed to find document id');
      }
    });
    }
    //execute DB task deletion
    await db
        .collection('projects')
        .doc(projectID)
        .collection('tasks')
        .doc(taskID)
        .delete();
  }

  archiveConfirmation(BuildContext context, projectID, taskID) {
    getCurrentMembers();
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
          await archiveTask(membersList);
        }catch(e){
          print(e);
        }
        Future.delayed(Duration.zero, () {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Task successfully archived!'),));
          Navigator.popUntil(context, (route) {
            return count++ == 2;
          });
        });
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Archive Confirmation"),
      content: Text("Are you sure to archive this task?"),
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
      Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => LocalSearchAppBarPage()),
    );
    break;

    case 1 :
      deleteConfirmation(context);
    break;

    case 2 :
      archiveConfirmation(context, projectID, taskID);
    break;
  }
}

showCompleteDialog(BuildContext context, projectID, taskID) {
  DateTime time = DateTime.now();
  List<Map<String, dynamic>> membersList = [];
  final db = Provider.of(context)!.db;
  void getCurrentMembers() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection('projects')
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
        getCurrentMembers();
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(projectID)
            .collection('tasks')
            .doc(taskID)
            .update(setCompleted(true, time));

        for(int i = 0; i<membersList.length ; i++) {
          final uid = membersList[i]['uid'];
          await db.collection('users_data')
              .doc(uid)
              .collection('event_data')
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

