import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/personal_spaces/archives/archive_project_settings.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

AppBar buildAppBar(BuildContext context, String title, String description, String projectID, List membersList) {
  return AppBar(
      centerTitle: true,
      iconTheme: IconThemeData(
          color: Colors
              .white), // set backbutton color here which will reflect in all screens.
      leading: BackButton(),
      backgroundColor: Colors.transparent,
      title: Text(title, style:TextStyle(fontFamily: 'Raleway')),
      elevation: 0,
      actions: [
        Theme(data: Theme.of(context).copyWith(
            dividerColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.white)
        ),
          //list if widget in appbar actions
          child:PopupMenuButton<int>(//don't specify icon if you want 3 dot menu
            color: Colors.blue,
            onSelected: (item) => onClicked(context, item, projectID, membersList, title, description),
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 0,
                child: Text("Project settings",style: TextStyle(color: Colors.black, fontFamily: 'Raleway'),),
              ),
              PopupMenuDivider(),
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: const [
                    Icon(Icons.delete, color: Colors.black),
                    SizedBox(width: 8),
                    Text("Delete Project",style: TextStyle(color: Colors.black, fontFamily: 'Raleway'),),
                  ],
                ),
              ),
            ],
          ),),
      ]
  );
}

void onClicked(BuildContext context, int item, projectID, membersList, title, description){
  int count = 0;
  Future removeProject() async{
    final db = FirebaseFirestore.instance;
    //execute delete from project DB (only admin can execute/ not function yet) -->

    //execute delete from project for every user's view
    for(int i = 0; i<membersList.length ; i++) {
      final uid = membersList[i]['uid'];
      await db
          .collection('projects_logDB')
          .doc(uid)
          .collection('project_archive')
          .doc(projectID)
          .delete();

      await db
          .collection('projects_logDB')
          .doc(uid)
          .collection('project_archive')
          .doc(projectID)
          .collection('task_archive')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs){
          ds.reference.delete();
        }});
    }
  }

  deleteConfirmation(BuildContext context) {
    final db = FirebaseFirestore.instance;
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
            await removeProject();
            Future.delayed(Duration.zero, () {
              Navigator.popUntil(context, (route) {
                return count++ == 2;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Project successfully deleted!'),));
            });
        }catch(e){
          print(e);
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete Confirmation"),
      content: Text("Are you sure to delete this project?"),
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
        MaterialPageRoute(builder: (context) => projectSettings(title:title, description:description, projectID:projectID)),
      );
      break;

    case 1 :
      deleteConfirmation(context);
      break;
  }
}

