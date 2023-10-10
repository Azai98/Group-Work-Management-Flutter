import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/constants.dart';
import 'package:collab/project_screens/widgets/button_widget.dart';
import 'package:collab/widgets/provider_widgets.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ignore: camel_case_types
class projectSettings extends StatefulWidget {
  final String title, description, projectID;
  const projectSettings({Key? key, required this.title, required this.description, required this.projectID}) : super(key: key);

  @override
  _projectSettings createState() => _projectSettings();
}

// ignore: camel_case_types
class _projectSettings extends State<projectSettings> {
  final _formKey = GlobalKey<FormState>(); // validation use
  DateTimeRange? dateRange; DateTimeRange? updatedDateRange;
  bool isLoading = false;
  Map<String, dynamic>? userMap;
  List<Map<String, dynamic>> membersList = [];
  List<Map<String, dynamic>> currentTask = [];
  List<Map<String, dynamic>> currentMember = [];
  List<Map<String, dynamic>> newMembers = [];
  List<Map<String, dynamic>> removeMembers = [];
  final Color? activeColor = Colors.pink[400];
  final Color? inActiveColor = Colors.grey[50];
  TextEditingController projectTitleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final double minValue = 8.0;
  int experienceIndex = 0;
  String creator = '';

  final TextStyle _errorStyle = TextStyle(
    color: Colors.red,
    fontSize: 16.6,
  );

  @override
  void initState() {
    super.initState();
    getCurrentMembers();
    getCurrentProjectDurations();
    getCurrentTasks();
    projectTitleController.text = widget.title;
    descriptionController.text = widget.description;
  }

  @override
  void dispose() {
    super.dispose();
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
            "isAdmin": value.data()!["members"][i]["isAdmin"]
          });
          currentMember.add({
            "username": value.data()!["members"][i]["username"].toString(),
            "email": value.data()!["members"][i]["email"].toString(),
            "uid": value.data()!["members"][i]["uid"].toString(),
            "isAdmin": value.data()!["members"][i]["isAdmin"]
          });
        }
        creator = value['project creator'];
      });
    });
  }

  void getCurrentProjectDurations() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    await db
        .collection('projects')
        .doc(widget.projectID)
        .get()
        .then((value) {
      setState(() {
        final initialDateRange = DateTimeRange(
          start: DateTime.parse(value['project start']),
          end: DateTime.parse(value['project end']).subtract(Duration(hours: 23, minutes : 59, seconds : 59)),
        );
        dateRange = initialDateRange;
        updatedDateRange = dateRange;
      });
    });
  }

  void getCurrentTasks() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await db.collection('projects').doc(widget.projectID).collection('tasks').get();
    final allTasks = querySnapshot.docs.map((doc) => doc.data()).toList();

    for(int i = 0; i<allTasks.length; i++){
      setState(() {
        currentTask.add({
          "task_name": (allTasks[i] as dynamic)['task_name'],
          "task_desc": (allTasks[i] as dynamic)['task_desc'],
          "assignee_name" : (allTasks[i] as dynamic)['assignee_name'],
          "assignee_email": (allTasks[i] as dynamic)['assignee_email'],
          'time': (allTasks[i] as dynamic)['time'],
          'completeTime': (allTasks[i] as dynamic)['completeTime'],
          "due_date" : (allTasks[i] as dynamic)['due_date'],
          "complete" : (allTasks[i] as dynamic)['complete'],
          "projectID": (allTasks[i] as dynamic)['projectID'],
          "taskID": (allTasks[i] as dynamic)['taskID'],
        });
      });
    }

  }


  Widget _buildName() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: minValue),
      child: TextFormField(
        controller: projectTitleController,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter a name';
          } else if (value.length < 4) {
            return 'Name must be 4';
          }
        },
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            errorStyle: _errorStyle,
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(vertical: minValue, horizontal: minValue),
            labelText: 'Project Name',
            labelStyle: TextStyle(fontSize: 16.0, color: Colors.black87)),
      ),
    );
  }

  Widget _buildEmail() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: minValue),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.text,
        validator: (value) {
                    bool isEmail(String email) => EmailValidator.validate(email);
                    String msg = '';
                    if (!isEmail(value!.trim())) {
                    msg = 'Please enter a valid email';
                    }
                    return msg;
                   },
        onChanged: (String value) {},
        decoration: InputDecoration(
            errorStyle: _errorStyle,
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(vertical: minValue, horizontal: minValue),
            labelText: 'Collaborator',
            labelStyle: TextStyle(fontSize: 16.0, color: Colors.black87)),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: minValue, vertical: minValue),
      child: TextFormField(
        controller: descriptionController,
        keyboardType: TextInputType.text,
        maxLines: 2,
        decoration: InputDecoration(
            errorStyle: _errorStyle,
            border: InputBorder.none,
            labelText: 'Project Description',
            contentPadding: EdgeInsets.symmetric(horizontal: minValue),
            labelStyle: TextStyle(fontSize: 16.0, color: Colors.black87)),
      ),
    );
  }

  Widget _buildTextBackground(Widget child) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(2)),
      child: child,
    );
  }

  Widget _buildSubmitBtn() {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(horizontal: minValue * 3),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
       ),
      child: RaisedButton(
          onPressed: () async {
            if(updatedDateRange != dateRange) {
              dateRange = updatedDateRange;
            }
            updateProject();
            Navigator.pop(context);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Project updated!'),));},
        padding: EdgeInsets.symmetric(vertical: minValue * 2.4),
        elevation: 0.0,
        color: Color(0xFFf1f4f9),
        textColor: Colors.white,
        child: Text('SAVE CHANGES', style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'Raleway', fontWeight: FontWeight.bold),),
      ),
    );
  }

  void onRemoveMembers(int index) {
    if (membersList[index]['isAdmin'] != true) {
      setState(() {
        //check if the user is added into membersList or not, if yes, remove the newMembers List.----- updating
        bool contain = newMembers.any((element) => element['uid'] == membersList[index]['uid']);
        if (contain == true) {
          newMembers.removeWhere((element) => element['uid'] == membersList[index]['uid']);
        }
        removeMembers.add({
          "username": membersList[index]['username'],
          "email": membersList[index]['email'],
          "uid": membersList[index]['uid'],
          "isAdmin": membersList[index]['isAdmin'],
        });
        membersList.removeAt(index);
      });
    }else{
      Fluttertoast.showToast(
        backgroundColor: Colors.grey,
        msg: "You cannot remove creator",
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
    }
  }

  void onSearch() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    try {
      await db
          .collection('users_data')
          .where("email", isEqualTo: _emailController.text)
          .get()
          .then((value) {
        setState(() {
          userMap = value.docs[0].data();
          isLoading = false;
        });
        print(userMap);
        Navigator.pop(context);
        showInformationDialog(context);
      });
    } catch (userMap) {
      Fluttertoast.showToast(
        backgroundColor: Colors.grey,
        msg: "User did not found or not exists",
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void onResultTap() {
    bool isAlreadyExist = false;

    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['uid'] == userMap!['uid']) {
        isAlreadyExist = true;
      }
    }

    bool contain = removeMembers.any((element) => element['uid'] == userMap!['uid']);
    if (contain == true) {
      removeMembers.removeWhere((element) => element['uid'] == userMap!['uid']);
    }

    if (!isAlreadyExist) {
      setState(() {
        membersList.add({
          "username": userMap!['username'],
          "email": userMap!['email'],
          "uid": userMap!['uid'],
          "isAdmin": false,
        });

        newMembers.add({
          "username": userMap!['username'],
          "email": userMap!['email'],
          "uid": userMap!['uid'],
          "isAdmin": false,
        });
        userMap = null;
      });
    }
  }

  //set date
  Future pickDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(Duration(hours: 24 * 3)),
    );
    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDateRange: dateRange,
    );

    if (newDateRange == null) return;

    setState(() => updatedDateRange = newDateRange);
  }

  String getFrom() {
    if (updatedDateRange == null) {
        return 'Initial date';
    } else {
      return DateFormat('MM/dd/yyyy').format(updatedDateRange!.start);
    }
  }

  String getUntil() {
    if (updatedDateRange == null) {
        return 'End date';
    } else {
      return DateFormat('MM/dd/yyyy').format(updatedDateRange!.end);
    }
  }

  Future<void> showInformationDialog(BuildContext context) async {
    final size = MediaQuery.of(context).size;
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder( // StatefulBuilder
              builder: (context, setState) {
                return Dialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                              'Manage Collaborator',
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black, fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      Flexible(
                        child: ListView.builder(
                          itemCount: membersList.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                          width: 0.5,
                                          color: kPrimaryLightColor,
                                        ))),
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      onRemoveMembers(index);
                                    });
                                  },
                                  leading: Icon(Icons.account_circle, color: kPrimaryLightColor),
                                  title: Text(membersList[index]['username'],style: GoogleFonts.montserrat(fontWeight: FontWeight.w400)),
                                  subtitle: Text(membersList[index]['email'], style: GoogleFonts.roboto()),
                                  trailing: Icon(Icons.close),
                                ));
                          },
                        ),
                      ),
                      SizedBox(
                        height: size.height / 50,
                      ),
                      Container(
                        height: size.height / 14,
                        width: size.width,
                        alignment: Alignment.center,
                        child: Container(
                          height: size.height / 14,
                          width: size.width / 1.15,
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                                hintText: "Enter your collaborator's email",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      onSearch();
                                    });
                                    setState(() {
                                      print(userMap);
                                    });
                                  },
                                  icon: Icon(Icons.search, color: Colors.indigo),
                                )
                            ),
                          ),
                        ),
                      ),
                      userMap != null
                          ? ListTile(
                        onTap: () {
                          setState(() {
                            onResultTap();
                          });
                        },
                        leading: Icon(Icons.account_box),
                        title: Text(userMap!['username']),
                        subtitle: Text(userMap!['email']),
                        trailing: Icon(Icons.add),
                      )
                          : SizedBox(),
                    ],
                  ),);
              }
          );});
  }

  Future<void> updateProject() async {
    final db = Provider.of(context)!.db;
    //update current projectDB
    await db.collection('projects').doc(widget.projectID).update({
      "members": membersList,
      "project start": dateRange!.start.toString(),
      "project end": dateRange!.end.add(Duration(hours: 23, minutes : 59, seconds : 59)).toString(),
    });

    //update current projectDB to current collaborator based on uid
    for (int i = 0; i < currentMember.length; i++) {
      String uid = currentMember[i]['uid'];
      var time = DateTime.now();

      if (currentMember[i]['isAdmin'] == false) { //set non-admin
        await db
            .collection('users_data')
            .doc(uid)
            .collection('users_project')
            .doc(widget.projectID)
            .update({
          "title": projectTitleController.text,
          'description': descriptionController.text,
          'time': 'project updated on: ' + time.toString(),
          'timestamp': time,
          "project start": dateRange!.start.toString(),
          "project end": dateRange!.end.add(Duration(hours: 23, minutes : 59, seconds : 59)).toString(),
          'isAdmin': false,
        });
      }
      else if (currentMember[i]['isAdmin'] == true) { //set admin
        await db
            .collection('users_data')
            .doc(uid)
            .collection('users_project')
            .doc(widget.projectID)
            .update({
          'title': projectTitleController.text,
          'description': descriptionController.text,
          'time': 'project updated on: ' + time.toString(),
          'timestamp': time,
          "project start": dateRange!.start.toString(),
          "project end": dateRange!.end.add(Duration(hours: 23, minutes : 59, seconds : 59)).toString(),
          'isAdmin': true,
        });
      }
      else{ //delete non-access user
        await db
            .collection('users_data')
            .doc(uid)
            .collection('users_project')
            .doc(widget.projectID)
            .delete();
      }
    }

    //add new collaborator to current projectDB based on uid
    if(newMembers.isNotEmpty) {
      for (int i = 0; i < newMembers.length; i++) {
        String uid = newMembers[i]['uid'];
        var time = DateTime.now();
        await db
            .collection('users_data')
            .doc(uid)
            .collection('users_project')
            .doc(widget.projectID)
            .set({
          "title": projectTitleController.text,
          'description': descriptionController.text,
          'time': 'project updated on: ' + time.toString(),
          'timestamp': time,
          "project start": dateRange!.start.toString(),
          "project end": dateRange!.end.add(Duration(hours: 23, minutes : 59, seconds : 59)).toString(),
          "project creator": creator,
          'isAdmin': false,
        });

        //assign current event data
        if(currentTask.isNotEmpty) {
          for(int i = 0; i<currentTask.length; i++) {
            await db.collection('users_data')
                .doc(uid)
                .collection('event_data')
                .doc(currentTask[i]['taskID'])
                .set({
              "task_name": currentTask[i]['task_name'],
              "task_desc": currentTask[i]['task_desc'],
              "assignee_name": currentTask[i]['assignee_name'],
              "assignee_email": currentTask[i]['assignee_email'],
              'time': currentTask[i]['time'],
              'completeTime': currentTask[i]['completeTime'],
              "due_date": currentTask[i]['due_date'],
              "complete": currentTask[i]['complete'],
              "projectID": currentTask[i]['projectID'],
              "taskID": currentTask[i]['taskID'],
            });
          }
        }
      }
    }

    //delete current collaborator from current projectDB based on uid
    if(removeMembers.isNotEmpty) {
      for (int i = 0; i < removeMembers.length; i++) {
        String uid = removeMembers[i]['uid'];
        await db
            .collection('users_data')
            .doc(uid)
            .collection('users_project')
            .doc(widget.projectID)
            .delete();

        //delete current event data
        if(currentTask.isNotEmpty) {
          for(int i = 0; i<currentTask.length; i++) {
            await db.collection('users_data')
                .doc(uid)
                .collection('event_data')
                .doc(currentTask[i]['taskID'])
                .delete();
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/feedback-four-bg.webp'),
                fit: BoxFit.cover)),
        child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.7)
          ])),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: minValue * 10,
                        ),
                        Text(
                          "Project Settings",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Raleway',
                              fontSize: 35.0,
                              color: Colors.white),
                        ),
                        SizedBox(
                          width: 110.0,
                          child: Container(
                            height: 4,
                            color: Colors.pink[400],
                          ),
                        ),
                        SizedBox(
                          height: minValue * 2,
                        ),
                        Text(
                          "Edit project name, collaborator, project date \n and description",
                          style: TextStyle(
                              fontSize: 16.0, color: Colors.grey[200],
                              fontFamily: 'Raleway'
                              ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: minValue * 3,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:[
                          Text(
                          "Project Details:",
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, fontFamily: 'Raleway'),
                          ),
                            ElevatedButton(
                              child: Text('Manage collaborator', style: TextStyle(fontFamily: 'Raleway', color: Colors.black)),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                maximumSize: size,
                              ),
                              onPressed: () async{
                                await showInformationDialog(context);
                              },
                            ),
                        ]),
                        SizedBox(
                          height: minValue * 3,
                        ),
                        _buildTextBackground(_buildName()),
                        //_buildTextBackground(_buildEmail()),
                        SizedBox(
                          height: minValue * 2,
                        ),
                        _buildTextBackground(_buildDescription()),
                        SizedBox(
                          height: minValue * 3,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(bottom: 20),
                          child: Text(
                          "Project Schedule:",
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, fontFamily: 'Raleway'),
                        ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ButtonWidget(
                                text: getFrom(),
                                onClicked: () => pickDateRange(context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ButtonWidget(
                                text: getUntil(),
                                onClicked: () => pickDateRange(context),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: minValue * 6,
                        ),
                        _buildSubmitBtn()
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
