import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/constants.dart';
import 'package:collab/firebase_file.dart';
import 'package:collab/project_screens/widgets/datetime_extensions.dart';
import 'package:collab/project_screens/widgets/date_picker_widget.dart';
import 'package:collab/project_screens/widgets/time_picker_widget.dart';
import 'package:collab/personal_spaces/archives/widgets/task_appbar_widget.dart';
import 'package:collab/widgets/provider_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:collab/database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

// ignore: camel_case_types
class archiveTaskDetails extends StatefulWidget {
  final String title, description, taskID, projectID;
  const archiveTaskDetails({Key? key, required this.title, required this.description, required this.taskID, required this.projectID}) : super(key: key);

  @override
  _archiveTaskDetails createState() => _archiveTaskDetails();
}

// ignore: camel_case_types
class _archiveTaskDetails extends State<archiveTaskDetails> {
  late Future<List<FirebaseFile>> futureFiles;
  int trueCounter = 0; int temp = 0; String taskID = ''; String projectID = ''; bool status = false;
  bool isLoading = false;
  UploadTask? task;
  List<File> file = []; String? percentage;
  late DatePickerWidget _date; late TimePickerWidget _time;
  String dueDate = ''; String dueTime = '';
  DateTime? completedTime; String completedTime_ = '';
  DateTime? dt; TimeOfDay? t;
  List<String> fileName = [];
  Map<String, dynamic>? assignee;
  Map<String, dynamic>? userMap;
  List<Map<String, dynamic>> membersList = [];
  var time = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  List<bool> _isChecked = [];
  TextEditingController descriptionController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    descriptionController.text = widget.description;
    titleController.text = widget.title;
    taskID = widget.taskID; projectID = widget.projectID;
    futureFiles = DatabaseService.listAll('projects/$projectID/$taskID');
    getCurrentTaskDetails();
    getCurrentMembers();
    getPermission();
  }

  void getPermission() async {
    print("getPermission");
    await Permission.storage.request();
  }

  void getCurrentTaskDetails() async {
    FirebaseFirestore db = FirebaseFirestore.instance; FirebaseAuth auth = FirebaseAuth.instance;

    await db
        .collection('projects_logDB')
        .doc(auth.currentUser!.uid)
        .collection('project_archive')
        .doc(widget.projectID)
        .collection('task_archive')
        .doc(widget.taskID)
        .get()
        .then((value) {
      setState(() {
        assignee = value.data();
        dueDate = assignee!['due_date'];
        status = assignee!['complete'];
        completedTime = DateTime.parse(value.data()!['completeTime'].toDate().toString());
      });
    });
    completedTime_ = DateFormat.yMd().add_jm().format(completedTime!).toString();
    DateTime dates = DateTime.parse(dueDate);
    dt = dates.datetime(dates);
    t = dates.daytime(dates);
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
    _isChecked = List<bool>.filled(membersList.length, false);
  }

  updateStatus(bool status) async{
    final db = Provider.of(context)!.db;
    //mapping
    Map<String, dynamic> updateProgress() => {
      'complete': status,
    };

    //update task in eventDB for every user
    for(int i = 0; i<membersList.length ; i++) {
      final uid = membersList[i]['uid'];
      await db
          .collection('projects_logDB')
          .doc(uid)
          .collection('project_archive')
          .doc(widget.projectID)
          .collection('task_archive')
          .doc(widget.taskID)
          .update(updateProgress());
    }
  }

  void onRemoveFiles(int index){
    setState(() {
      file.removeAt(index);
    });
  }

  Future onDeleteCloudFile(String filePath) async{
    try {
      if(mounted) {
        setState(() {
          Reference storageReference = FirebaseStorage.instance.ref();
          storageReference.child(filePath).delete();
        });
      }
    }catch(e){
      print(e);
    }
    Future.delayed(Duration(milliseconds: 50), () {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: buildAppBar(context, widget.projectID, widget.taskID, status, completedTime_),
      body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: width,
                    decoration: BoxDecoration(
                        color: Color(0xFFF1F4F9),
                        border: Border(
                            bottom: BorderSide(
                              width: 1,
                              color: kPrimaryLightColor,
                            ))),
                    height: 50,
                    padding: EdgeInsets.only(top: 5),
                    child: SizedBox(
                        child:Container(
                            width: size.width * 0.8,
                            margin: EdgeInsets.only(left: 20),
                            child: TextFormField(
                              // Handles Form Validation
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your title';
                                }
                                return null;
                              },
                              controller: titleController,
                              style: TextStyle(fontSize: 20, fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter task title',
                              ),
                            )))),
                Container(
                  width: width,
                  decoration: BoxDecoration(
                      color: Color(0xFFF1F4F9),
                      border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: kPrimaryLightColor,
                          ))),
                  child: SizedBox(
                      child:Container(
                          width: size.width * 0.8,
                          margin: EdgeInsets.only(left: 20),
                          child: TextFormField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            // Handles Form Validation
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your description';
                              }
                              return null;
                            },
                            controller: descriptionController,
                            style: TextStyle(fontSize: 17, fontFamily: 'Raleway', fontWeight: FontWeight.normal),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter task description',
                            ),
                          ))
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  alignment: Alignment.topLeft,
                  width: width,
                  decoration: BoxDecoration(
                      color: Color(0xFFF1F4F9),
                      border: Border.all(
                        width: 1,
                        color: kPrimaryLightColor,
                      )),
                  height: 100,
                  padding: EdgeInsets.only(top: 15,left: 10),
                  child: Column(
                      children:[
                        Row(
                            children:[
                              Icon(
                                Icons.person, color: Colors.indigoAccent,
                              ),
                              Container(
                                  margin: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    'Assignee',
                                    style: TextStyle(fontSize: 20, color: Colors.black,fontFamily: 'Raleway',fontWeight: FontWeight.bold),
                                  )),
                            ]
                        ),
                        SizedBox(height: 5),
                        Row(
                            children:[
                              SizedBox(height: 50),
                              Icon(
                                Icons.email, color: Colors.indigoAccent,
                              ),
                              Container(
                                  width:250,
                                  margin: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    assignee?['assignee_email'] ?? assignee?['email'] ?? 'Anonymous', softWrap: true,
                                    style: TextStyle(fontSize: 15, color: Colors.black,fontFamily: 'Raleway',fontWeight: FontWeight.bold),
                                  )),
                            ]
                        ),
                      ]
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  alignment: Alignment.centerLeft,
                  width: width,
                  decoration: BoxDecoration(
                      color: Color(0xFFF1F4F9),
                      border: Border.all(
                        width: 1,
                        color: kPrimaryLightColor,
                      )),
                  child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 10,top: 15, bottom: 15),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: const [
                                  Icon(Icons.date_range, color: Colors.indigoAccent),
                                  SizedBox(width: 10),
                                  Text('Due date', style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Raleway')),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children:[
                              _date = DatePickerWidget(dt: dt),
                              _time = TimePickerWidget(t: t),
                            ]
                        ),
                        SizedBox(height: 10),
                      ]
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  alignment: Alignment.centerLeft,
                  width: width,
                  decoration: BoxDecoration(
                      color: Color(0xFFF1F4F9),
                      border: Border.all(
                        width: 1,
                        color: kPrimaryLightColor,
                      )),
                  child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                icon: Icon(Icons.add, color: Colors.indigoAccent),
                                label: Text('Attachment', style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Raleway')),
                                onPressed: (){
                                },
                              ),
                            ),
                          ],
                        ),
                        FutureBuilder<List<FirebaseFile>>(
                            future: futureFiles,
                            builder: (context, snapshot){
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return Center(child: CircularProgressIndicator());
                                default:
                                  if (snapshot.hasError) {
                                    return Center(child: Text('Some error occurred!'));
                                  } else {
                                    final files = snapshot.data!;
                                    return Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child:Row(
                                          children: [
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount: files.length,
                                                shrinkWrap: true,
                                                physics: NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  final file = files[index];
                                                  return Container(
                                                      margin: EdgeInsets.only(left: 10),
                                                      decoration: BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                width: 0.5,
                                                                color: Colors.grey,
                                                              ))),
                                                      child: ListTile(
                                                        leading: Icon(Icons.attach_file_sharp, color: Colors.indigoAccent),
                                                        title: Text(file.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                                        trailing: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children:[
                                                              IconButton(
                                                                  onPressed: ()async{
                                                                    if (await Permission.storage.request().isGranted) {
                                                                      await DatabaseService.downloadFile(file.url, file.name, file.ref);
                                                                      final snackBar = SnackBar(
                                                                        content: Text('Downloaded ${file.name}'),
                                                                      );
                                                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                    }
                                                                  }, icon: Icon(Icons.download)),
                                                              IconButton(
                                                                  onPressed: () {
                                                                    String filePath = 'projects/$projectID/$taskID/${file.name}';
                                                                    showConfirmationDialog(context, filePath);
                                                                  }, icon: Icon(Icons.delete)),
                                                            ]
                                                        ),
                                                      )
                                                  );
                                                },
                                              ),
                                            ),
                                          ],)
                                    );
                                  }
                              }
                            }
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child:Row(
                              children: [
                                Expanded(
                                  child:ListView.builder(
                                      itemCount: file.length,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index){
                                        return Container(
                                            decoration: BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                                      width: 0.5,
                                                      color: Colors.grey,
                                                    ))),
                                            child: ListTile(
                                              leading: Icon(Icons.attach_file_sharp, color: Colors.indigoAccent),
                                              title: Text(fileName[index], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                              trailing: IconButton(onPressed: () {onRemoveFiles(index);}, icon: Icon(Icons.remove)),
                                            )
                                        );
                                      }
                                  ),
                                ),
                                SizedBox(height: 10),
                              ]
                          ),
                        ),
                      ]
                  ),
                ),
              ],
            ),)
      ),
    );
  }

  showConfirmationDialog(BuildContext context, String filePath) {
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
        try {
          await onDeleteCloudFile(filePath);
          setState(() {
            Future.delayed(Duration(milliseconds: 100), () {
              Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) =>
                      archiveTaskDetails(
                          title: widget.title,
                          description: widget.description,
                          projectID: widget.projectID,
                          taskID: widget.taskID
                      )));
            });
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'File successfully removed from cloud'),));
        }catch(e){
          print(e);
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text("Are you sure to remove the file from Cloud?"),
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
}
