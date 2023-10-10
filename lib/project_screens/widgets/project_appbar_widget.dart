import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/project_screens/collaborator_list.dart';
import 'package:collab/project_screens/project_settings.dart';
import 'package:collab/search_appbar_page.dart';
import 'package:collab/widgets/provider_widgets.dart';
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
    title: Text(title, style:TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
    elevation: 0,
      actions: [
        Theme(data: Theme.of(context).copyWith(
            dividerColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.white)
        ),
          //list if widget in appbar actions
          child:PopupMenuButton<int>(//don't specify icon if you want 3 dot menu
            color: Color(0xFFBDBDBD).withOpacity(0.9),
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
                    Icon(Icons.search, color: Colors.black),
                    SizedBox(width: 8),
                    Text("Search",style: TextStyle(color: Colors.black, fontFamily: 'Raleway'),),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem<int>(
                value: 2,
                child: Row(
                  children: const [
                    Icon(Icons.delete, color: Colors.black),
                    SizedBox(width: 8),
                    Text("Delete Project",style: TextStyle(color: Colors.black, fontFamily: 'Raleway'),),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem<int>(
                value: 3,
                child: Row(
                  children: const [
                    Icon(Icons.archive, color: Colors.black),
                    SizedBox(width: 8),
                    Text("Archive Project",style: TextStyle(color: Colors.black, fontFamily: 'Raleway'),),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem<int>(
                value: 4,
                child: Row(
                  children: const [
                    Icon(Icons.person, color: Colors.black),
                    SizedBox(width: 8),
                    Text("Collaborator",style: TextStyle(color: Colors.black, fontFamily: 'Raleway'),),
                  ],
                ),
              ),
            ],
          ),),
      ]
  );
}

void onClicked(BuildContext context, int item, projectID, List membersList, title, description){
   int count = 0;
   Future removeProject() async{
    final db = FirebaseFirestore.instance;
    //execute delete from project DB (only admin can execute/ not function yet) -->

    //execute delete from project for every user's view
    for(int i = 0; i<membersList.length ; i++) {
      final uid = membersList[i]['uid'];
      await db
          .collection('users_data')
          .doc(uid)
          .collection('users_project')
          .doc(projectID)
          .delete();
    }

    //execute delete from project project -> tasks
    await db
        .collection('projects')
        .doc(projectID)
        .collection('tasks')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs){
        ds.reference.delete();
      }});

    //remove projectID
    await db
        .collection('projects')
        .doc(projectID)
        .delete();
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
           QuerySnapshot snapshots = await db.collection('projects').doc(projectID).collection('tasks').get();
           if(snapshots.docs.isNotEmpty){
             Fluttertoast.showToast(
               backgroundColor: Colors.grey,
               msg: "You need to complete or archive all tasks before you can delete!",
               gravity: ToastGravity.CENTER,
               fontSize: 16.0,
             );
             Navigator.pop(context);
           }else {
             await removeProject();
             Future.delayed(Duration.zero, () {
               Navigator.popUntil(context, (route) {
                 return count++ == 2;
               });
               ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: const Text('Project successfully deleted!'),));
             });
           }
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

   archiveProject(String projectID) async {
     final db = Provider.of(context)!.db;
     final auth = Provider.of(context)!.auth;

     for (int i = 0; i < membersList.length; i++) {
       final uid = membersList[i]['uid'];
       var oldCollection = db.collection('users_data').doc(uid).collection('users_project').doc(projectID);
       var newCollection = db.collection('projects_logDB').doc(uid).collection('project_archive')
                            .doc(oldCollection.id);

       DocumentSnapshot snapshot = await oldCollection.get().then((
           docSnapshot) {
         if (docSnapshot.exists) {
           // document id does exist
           print('Successfully found document');
           newCollection
               .set({
             "members": membersList,
             "projectID": projectID,
             "project start": docSnapshot['project start'],
             "project end": docSnapshot['project end'],
             "project creator": docSnapshot['project creator'],
             "isAdmin": docSnapshot['isAdmin'],
             "time": docSnapshot['time'],
             "timestamp": docSnapshot['timestamp'],
             "title": docSnapshot['title'],
             "description": docSnapshot['description'],
           })
               .then((value) => print("document moved to different collection"))
               .catchError((error) => print("Failed to move document: $error"))
               .then((value) async =>
           ({

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
     //remove projectID
     await db
         .collection('projects')
         .doc(projectID)
         .delete();
   }

   archiveConfirmation(BuildContext context) {
     final db = Provider.of(context)!.db;
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
           QuerySnapshot snapshots = await db.collection('projects').doc(projectID).collection('tasks').get();
           if(snapshots.docs.isNotEmpty){
             Fluttertoast.showToast(
               backgroundColor: Colors.grey,
               msg: "You need to complete or archive all tasks before you can archive!",
               gravity: ToastGravity.CENTER,
               fontSize: 16.0,
             );
             Navigator.pop(context);
           }else {
             await archiveProject(projectID);
             Future.delayed(Duration.zero, () {
               Navigator.popUntil(context, (route) {
                 return count++ == 2;
               });
               ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: const Text('Project successfully archived!'),));
             });
           }
         }catch(e){
           print(e);
         }
       },
     );
     // set up the AlertDialog
     AlertDialog alert = AlertDialog(
       title: Text("Archive Confirmation"),
       content: Text("Are you sure to archive this project?"),
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
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => LocalSearchAppBarPage()),
      );
      break;

    case 2 :
        deleteConfirmation(context);
        break;

    case 3 :
        archiveConfirmation(context);
        break;

    case 4 :
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => CollaboratorList(projectID: projectID)),
      );
       break;
  }
}

