import 'dart:io';

import 'package:collab/project_screens/widgets/datetime_extensions.dart';
import 'package:collab/project_screens/widgets/date_picker_widget.dart';
import 'package:collab/project_screens/widgets/time_picker_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:collab/widgets/provider_widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:collab/database.dart';
import 'package:path/path.dart' as Path;

class AddTasks extends StatefulWidget {
  final String projectID;
  const AddTasks({Key? key, required this.projectID}) : super(key: key);

  @override
  _AddTasks createState() => _AddTasks();
}

class _AddTasks extends State<AddTasks> {
  final _formKey = GlobalKey<FormState>();
  UploadTask? task;
  List<File> file = [];
  List<String> fileName = [];
  String taskID = ''; String? percentage;
  DatePickerWidget? date; TimePickerWidget? _time;
  DateTime? dueDate; TimeOfDay? dueTime;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  int trueCounter = 0; int temp = 0;
  bool isLoading = false; List<bool> _isChecked = [];
  Map<String, dynamic>? userMap;
  Map<String, dynamic>? assignee;
  List<Map<String, dynamic>> membersList = [];
  TextEditingController taskName = TextEditingController();
  TextEditingController taskDesc = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentMembers();
    taskID = Uuid().v1();
  }

  //trigger add
  addTasks(String projectID) async {
    final db = Provider.of(context)!.db;
    final dateTime = dueDate!.applied(dueTime!);
    var time = DateTime.now();

    setState(() {
      isLoading = true;
    });

    //create new task to selected projectDB
    await db.collection('projects')
            .doc(projectID)
            .collection('tasks')
            .doc(taskID)
            .set({
      "task_name": taskName.text,
      "task_desc": taskDesc.text,
      "assignee_name" : assignee?['username'],
      "assignee_email": assignee?['email'],
      'time': 'task created on: ' + time.toString(),
      'completeTime': time,
      "due_date" : dateTime.toString(),
      "complete" : false,
      "projectID": widget.projectID,
      "taskID": taskID
    });

    //create new task to every users eventDB
    for(int i = 0; i<membersList.length ; i++) {
      final uid = membersList[i]['uid'];
      await db.collection('users_data')
          .doc(uid)
          .collection('event_data')
          .doc(taskID)
          .set({
        "task_name": taskName.text,
        "task_desc": taskDesc.text,
        "assignee_name" : assignee?['username'],
        "assignee_email": assignee?['email'],
        'time': 'task created on: ' + time.toString(),
        'completeTime': time,
        "due_date" : dateTime.toString(),
        "complete" : false,
        "projectID": widget.projectID,
        "taskID": taskID
      });
    }

    await uploadFile();
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
    _isChecked = List<bool>.filled(membersList.length, false);
  }

  void onResultSelected(bool selected, String uid) async{
    FirebaseFirestore db = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    await db
        .collection('users_data')
        .where("uid", isEqualTo: uid)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      // ignore: avoid_print
      print(userMap);
    });

    if (selected == true) {
      setState(() {
        assignee = userMap;
        userMap = null;
      });
    }else{
      setState(() {
        assignee = null;
        userMap = null;
      });
    }
  }

  void onRemoveMembers(int index) {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (membersList[index]['uid'] != auth.currentUser!.uid) {
      setState(() {
        membersList.removeAt(index);
      });
    }
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path!;

    setState((){
      file.add(File(path));
      fileName.add(Path.basename(File(path).path));
      });
  }

  Future uploadFile() async {
    if (file.isEmpty) return;

    task = DatabaseService.uploadFileForTask(file, widget.projectID, taskID);
    showLoaderDialog(context);
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    print('Download-Link: $urlDownload');
  }

  void onRemoveFiles(int index){
    setState(() {
      file.removeAt(index);
    });
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
    stream: task.snapshotEvents,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final snap = snapshot.data!;
        final progress = snap.bytesTransferred / snap.totalBytes;
        percentage = (progress * 100).toStringAsFixed(2);

        if(percentage == '100.00'){
          int count = 0;
          Navigator.of(context).popUntil((_) => count++ >= 1);
          Future.delayed(Duration.zero, () {
            Navigator.pop(context);
          });
          Fluttertoast.showToast(
            backgroundColor: Colors.grey,
            msg: "Task successfully created",
            gravity: ToastGravity.CENTER,
            fontSize: 16.0,
          );
        }

        return Text(
          'Uploading attachment...',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        );
      } else {
        return Text(
          'Uploading attachment...',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        );
      }
    },
  );


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: Color(0xFF616161), title: Text('New Tasks', style: TextStyle(fontFamily: 'Raleway'),)),
      body: Form(
          key: _formKey,
          child:SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
             TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your title';
                  }
                  return null;
                },
                controller: taskName,
                decoration: InputDecoration(
                    labelText: 'Enter Title', border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your description';
                  }
                  return null;
                },
                controller: taskDesc,
                maxLines: 4,
                decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: 'Enter Description',
                    border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              Divider(
                  color: Colors.grey
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    TextButton.icon(
                        icon: Icon(Icons.person),
                        label: Text(
                          'Assign member',
                          style: TextStyle(fontSize: 20, color: Colors.black,fontFamily: 'Raleway',fontWeight: FontWeight.bold),
                        ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder( // StatefulBuilder
                                      builder: (context, setState) {
                                        return Dialog(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.only(top:15),
                                                    padding: EdgeInsets.only(left:10,right:10),
                                                    decoration: BoxDecoration(
                                                        border: Border(
                                                            bottom: BorderSide(
                                                              color: kPrimaryLightColor,
                                                              width: 2,
                                                            ))),
                                                    child:Text(
                                                      'Assign member',
                                                      style: TextStyle(
                                                          fontSize: 18.0, color: Colors.black, fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(top:20),
                                                child: ListView.builder(
                                                    itemCount: membersList.length,
                                                    shrinkWrap: true,
                                                    physics: NeverScrollableScrollPhysics(),
                                                    itemBuilder: (context, index) {
                                                      return Container(
                                                        child: CheckboxListTile(
                                                          value: _isChecked[index],
                                                          onChanged: (newValue) {
                                                            setState(() {
                                                              if (newValue == true) {
                                                                trueCounter = trueCounter + 1;
                                                                if (trueCounter == 1) {
                                                                  temp = index;
                                                                  _isChecked[index] =
                                                                  newValue!;
                                                                }
                                                                else if (trueCounter > 1) {
                                                                  _isChecked[temp] = false;
                                                                  temp = index;
                                                                  _isChecked[index] =
                                                                  newValue!;
                                                                  trueCounter =
                                                                      trueCounter - 1;
                                                                }
                                                              }
                                                              else {
                                                                trueCounter = trueCounter - 1;
                                                                _isChecked[index] = newValue!;
                                                              }
                                                            });
                                                            onResultSelected(
                                                                _isChecked[index],
                                                                membersList[index]['uid']);
                                                            print(newValue);
                                                          },
                                                          title: Text(
                                                              membersList[index]['username']),
                                                          subtitle: Text(
                                                              membersList[index]['email']),
                                                          secondary: Icon(
                                                              Icons.person_rounded,
                                                              color: kPrimaryLightColor),
                                                        ),
                                                      );
                                                    }),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    primary: Color(0xFFfab82b), padding: EdgeInsets.symmetric(horizontal: 30)),
                                                child: Text(
                                                  'Done',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ),
                                              SizedBox(height: 20)
                                            ],
                                          ),
                                        );
                                      });});
                          },
                        ),
                  ]
              ),
              Container(
                height: 40,
                margin:EdgeInsets.only(left:10),
                child:Row(
                children: [
                  Icon(
                    Icons.email, color: Colors.indigoAccent,
                  ),
                  Flexible(
                      child:  Container(
                      margin: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        assignee?['assignee_email'] ?? assignee?['email'] ?? 'Unassigned', softWrap: true,
                        style: TextStyle(fontSize: 15, color: Colors.black,fontFamily: 'Raleway',fontWeight: FontWeight.bold),
                      )),
                  )
                ],
              ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(
                      color: Colors.grey
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          icon: Icon(Icons.add, color: Colors.indigoAccent),
                          label: Text('Add attachment', style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Raleway')),
                          onPressed: () async{
                            await selectFile();
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child:Row(
                        children: [
                          Flexible(
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
                        ]
                    ),
                  ),
                  SizedBox(
                    height: size.height / 35,
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                      height: 1,
                      child: Container(
                      color: Colors.grey
                      ),
                  ),
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
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children:[
                        date = DatePickerWidget(dt: null),
                        _time = TimePickerWidget(t: null),
                      ]
                  ),
                  SizedBox(
                    height: size.height / 35,
                  ),
                ],
              ),
              SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ButtonStyle(backgroundColor:
                    MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.purple.shade100;
                          }
                          return Theme.of(context).primaryColor;
                        })),
                    child: Text(
                      'Add Task',
                      style: TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      dueDate = date!.getDate();
                      dueTime = _time!.getTime();
                      if (_formKey.currentState!.validate() && assignee != null && dueDate != null && dueTime != null) {
                        addTasks(widget.projectID);
                        if(file.isEmpty){
                          Navigator.pop(context);
                          Fluttertoast.showToast(
                            backgroundColor: Colors.grey,
                            msg: "Task successfully created",
                            gravity: ToastGravity.CENTER,
                            fontSize: 16.0,
                          );
                        }
                      }
                      else{
                        Fluttertoast.showToast(
                          backgroundColor: Colors.grey,
                          msg: "You must assign a member and schedule the date for task",
                          gravity: ToastGravity.CENTER,
                          fontSize: 16.0,
                        );
                      }
                    },
                  ))
            ],
          ))),
    );
  }

  showLoaderDialog(BuildContext context){
    AlertDialog alert=AlertDialog(
      content:  Row(
        children: [
          CircularProgressIndicator(),
          Container(
              alignment: Alignment.center,
              height: 100.0,
              margin: EdgeInsets.only(left: 7), child:task != null ? buildUploadStatus(task!) : Text('Uploading attachment...')),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
      return alert;
      },
    );
  }


}