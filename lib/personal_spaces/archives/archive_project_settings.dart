import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/constants.dart';
import 'package:collab/project_screens/widgets/button_widget.dart';
import 'package:collab/widgets/provider_widgets.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  DateTimeRange? dateRange;
  bool isLoading = false;
  Map<String, dynamic>? userMap;
  List<Map<String, dynamic>> membersList = [];
  List<Map<String, dynamic>> newMembers = [];
  List<Map<String, dynamic>> removeMembers = [];
  final Color? activeColor = Colors.pink[400];
  final Color? inActiveColor = Colors.grey[50];
  TextEditingController projectTitleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final double minValue = 8.0;
  int experienceIndex = 0;

  final TextStyle _errorStyle = TextStyle(
    color: Colors.red,
    fontSize: 16.6,
  );

  @override
  void initState() {
    super.initState();
    getCurrentMembers();
    getCurrentProjectDurations();
    projectTitleController.text = widget.title;
    descriptionController.text = widget.description;
  }

  @override
  void dispose() {
    super.dispose();
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
            "isAdmin": value.data()!["members"][i]["isAdmin"]
          });
        }
      });
    });
  }

  void getCurrentProjectDurations() async {
    FirebaseFirestore db = FirebaseFirestore.instance; FirebaseAuth auth = FirebaseAuth.instance;

    await db
        .collection('projects_logDB')
        .doc(auth.currentUser!.uid)
        .collection('project_archive')
        .doc(widget.projectID)
        .get()
        .then((value) {
      setState(() {
        final initialDateRange = DateTimeRange(
          start: DateTime.parse(value['project start']),
          end: DateTime.parse(value['project end']),
        );
        dateRange = initialDateRange;
      });
    });
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
                                  leading: Icon(Icons.account_circle, color: kPrimaryLightColor),
                                  title: Text(membersList[index]['username'],style: GoogleFonts.montserrat(fontWeight: FontWeight.w400)),
                                  subtitle: Text(membersList[index]['email'], style: GoogleFonts.roboto()),
                                  trailing: Icon(Icons.close),
                                ));
                          },
                        ),
                      ),
                    ],
                  ),);
              }
          );});
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
