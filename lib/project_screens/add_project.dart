import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/constants.dart';
import 'package:collab/project_screens/widgets/button_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:collab/widgets/provider_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddProject extends StatefulWidget {
  const AddProject({Key? key}) : super(key: key);

  @override
  _AddProject createState() => _AddProject();
}

class _AddProject extends State<AddProject> {
  final _formKey = GlobalKey<FormState>();
  DateTimeRange? dateRange;
  bool isLoading = false;
  Map<String, dynamic>? userMap;
  List<Map<String, dynamic>> membersList = [];
  final TextEditingController _search = TextEditingController();
  TextEditingController projectTitleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  //trigger add
  addProject() async {
    final auth = Provider.of(context)!.auth;
    final db = Provider.of(context)!.db;
    String creator = '';

    setState(() {
      isLoading = true;
    });

    String projectID = Uuid().v1();

    //get creator name
    await FirebaseFirestore.instance
        .collection('users_data')
        .doc(auth.getCurrentUID())
        .get().then((result) {
      creator = result.data()!['username'];
    });

    //create new projectDB
    await db.collection('projects').doc(projectID).set({
      "members": membersList,
      "projectID": projectID,
      "project start": dateRange!.start.toString(),
      "project end": dateRange!.end.add(Duration(hours: 23, minutes : 59, seconds : 59)).toString(),
      "project creator": creator
    });

    //create new project to every assignee based on uid
    for (int i = 0; i < membersList.length; i++) {
      String uid = membersList[i]['uid'];
      var time = DateTime.now();

      await db
          .collection('users_data')
          .doc(uid)
          .collection('users_project')
          .doc(projectID)
          .set({
        "title": projectTitleController.text,
        'description': descriptionController.text,
        'time': time.toString(),
        'timestamp': time,
        "project start": dateRange!.start.toString(),
        "project end": dateRange!.end.add(Duration(hours: 23, minutes : 59, seconds : 59)).toString(),
        "project creator": creator,
        'isAdmin' : false,
      });
    }

    //set admin
    String uid = auth.getCurrentUID();
    var time = DateTime.now();
    await db
        .collection('users_data')
        .doc(uid)
        .collection('users_project')
        .doc(projectID)
        .set({
      'title': projectTitleController.text,
      'description': descriptionController.text,
      'time': time.toString(),
      'timestamp': time,
      "project start": dateRange!.start.toString(),
      "project end": dateRange!.end.add(Duration(hours: 23, minutes : 59, seconds : 59)).toString(),
      "project creator": creator,
      'isAdmin' : true,
    });
  }

  void onSearch() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    try {
      await db
          .collection('users_data')
          .where("email", isEqualTo: _search.text)
          .get()
          .then((value) {
        setState(() {
          userMap = value.docs[0].data();
          isLoading = false;
        });
        print(userMap);
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

  void getCurrentUserDetails() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;

    await db
        .collection('users_data')
        .doc(auth.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        membersList.add({
          "username": value['username'],
          "email": value['email'],
          "uid": value['uid'],
          "isAdmin" : true,
        });
      });
    });
  }

  void onResultTap() {
    bool isAlreadyExist = false;

    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['uid'] == userMap!['uid']) {
        isAlreadyExist = true;
      }
    }

    if (!isAlreadyExist) {
      setState(() {
        membersList.add({
          "username": userMap!['username'],
          "email": userMap!['email'],
          "uid": userMap!['uid'],
          "isAdmin": false,
        });

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
    }else{
      Fluttertoast.showToast(
        backgroundColor: Colors.grey,
        msg: "You cannot remove creator",
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
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

    setState(() => dateRange = newDateRange);
  }

  String getFrom() {
    if (dateRange == null) {
      return 'Initial date';
    } else {
      return DateFormat('MM/dd/yyyy').format(dateRange!.start);
    }
  }

  String getUntil() {
    if (dateRange == null) {
      return 'End date';
    } else {
      return DateFormat('MM/dd/yyyy').format(dateRange!.end);
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: Color(0xFF616161), title: Text('New Projects', style: TextStyle(fontFamily:'Raleway'),)),
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
                controller: projectTitleController,
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
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: 'Enter Description',
                    border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              Divider(
                  color: Colors.grey
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(left: 10),
                child: Text('- Add member -', style: TextStyle(fontSize: 20, fontFamily: 'Raleway',fontWeight: FontWeight.bold),),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                          onTap: () => onRemoveMembers(index),
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
                    child: SizedBox(
                      height: size.height / 14,
                      width: size.width / 1.15,
                      child: TextFormField(
                        controller: _search,
                        decoration: InputDecoration(
                          hintText: "Enter your collaborator's email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            onPressed: onSearch,
                            icon: Icon(Icons.search, color: Colors.indigo),
                          )
                        ),
                      ),
                    ),
                  ),
                  isLoading
                      ? Container(
                    height: 30,
                    width: size.height / 12,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )
                      : Container (
                      width: size.height / 12,
                  ),
                  userMap != null
                      ? ListTile(
                    onTap: onResultTap,
                    leading: Icon(Icons.account_box),
                    title: Text(userMap!['username']),
                    subtitle: Text(userMap!['email']),
                    trailing: Icon(Icons.add),
                  )
                      : SizedBox(),
                ],
              ),
              SizedBox(height: 10),
              Divider(
                  color: Colors.grey
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(left: 10),
                child: Text('- Set project duration -', style: TextStyle(fontSize: 20, fontFamily: 'Raleway',fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ButtonWidget(
                      text: getFrom(),
                      onClicked: () => pickDateRange(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ButtonWidget(
                      text: getUntil(),
                      onClicked: () => pickDateRange(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
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
                      'Add Project',
                      style: TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate() && dateRange != null) {
                        addProject();
                        Navigator.pop(context);
                        Fluttertoast.showToast(msg: 'Project successfully created');
                      }
                      else{
                        Fluttertoast.showToast(msg: 'Please schedule your project');
                      }
                    },
                  ))
            ],
          ))),
    );
  }
}
