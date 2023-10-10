import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/main.dart';
import 'package:collab/project_screens/project_details.dart';
import 'package:collab/project_screens/task_details.dart';
import 'package:collab/search_appbar_page.dart';
import 'package:flutter/material.dart';
import 'package:collab/app_screens/profile_page.dart';
import 'package:collab/profile_screens/user/user.dart' as u;
import 'package:collab/widgets/provider_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget{
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage>{
  get onPressed => null;
  u.User user = u.User("","","","","");
  final TextEditingController _userNameController = TextEditingController();
  DateTime dateToday = DateTime.now();
  String? _today;

  @override
  void initState(){
    super.initState();
    _today = DateFormat.E().format(dateToday);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of(context)!.auth;
    final db = Provider.of(context)!.db;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery. of(context). size. height;
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar : AppBar(leading: Builder(
              builder: (BuildContext context) {
              return IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => LocalSearchAppBarPage()),);},
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text("Notification Feeds", style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.account_circle_rounded),
              highlightColor: Colors.lightBlueAccent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => profilePage()),
                );
              },
            ),
          ],),
    body : Stack(
          children:<Widget>[
          Container(
          decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/feed-ui.webp'),
              fit: BoxFit.cover)),
          ),
          Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.7)
                  ])),
          ),
          SafeArea(
          child:SingleChildScrollView(
          child:Stack(
               children: <Widget>[
                 StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                     stream: db
                         .collection('users_data')
                         .doc(auth.getCurrentUID())
                         .snapshots(),
                     builder: (context, snapshot) {
                       if (snapshot.connectionState == ConnectionState.done) {
                         _userNameController.text = user.username;
                       }
                       var userDocument = snapshot.data;
                       return Positioned(
                           top:0.0,
                           left: 0.0,
                           // ignore: prefer_adjacent_string_concatenation
                           child: Container(
                               width: width,
                               padding: const EdgeInsets.all(15),
                                   child:Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                     Row(
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                         children: [
                                           Text('Welcome Back, ', softWrap: true, style: GoogleFonts.ubuntuMono(
                                               color: Colors.white,
                                               fontWeight: FontWeight.w600,
                                               fontSize: 32.0)),
                                           Text('$_today', style: GoogleFonts.ubuntuMono(
                                               color: Colors.white,
                                               fontWeight: FontWeight.w600,
                                               fontSize: 32.0))
                                                ]
                                         ),
                                     SizedBox(height: 10),
                                     Text('${userDocument?['username']}', softWrap: true, style: GoogleFonts.ubuntuMono(color: Colors.white, fontSize: 30.0))
                                      ],
                                   ))
                       );
                     }
                 ),
                 StreamBuilder<QuerySnapshot>(
                   stream: db
                       .collection('users_data')
                       .doc(auth.getCurrentUID())
                       .collection('event_data')
                       .snapshots(),
                   builder: (context, snapshot) {
                     if (snapshot.connectionState == ConnectionState.waiting) {
                       return  Container(
                           height: MediaQuery.of(context).size.height * 0.8,
                           alignment: Alignment.center,
                           child: CircularProgressIndicator()
                       );
                     } else {
                       var docs = snapshot.data!.docs;
                       List user = [];
                       for(int i = 0; i< docs.length; i++){
                         if(docs[i]['assignee_email'] == auth.getUser()!.email){
                           user.add(docs[i]);
                         }
                       }
                       if(user.isEmpty){
                         return Container(
                             height: MediaQuery.of(context).size.height * 0.8,
                             alignment: Alignment.center,
                             child:Text("No Feeds. \nCurrently you have no notifications",
                               style: TextStyle( color: Colors.white, fontFamily: 'Raleway', fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,)
                         );
                       }
                       else {
                         return Container(
                           padding: EdgeInsets.only(top:125),
                           child: ListView.builder(
                           physics: const NeverScrollableScrollPhysics(),
                           scrollDirection: Axis.vertical,
                           shrinkWrap: true,
                           itemCount: user.length,
                           itemBuilder: (context, index) {
                             var time = (user[index]['completeTime'] as Timestamp).toDate();
                             DateTime due = DateTime.parse(
                                 user[index]['due_date']);

                             return Container(
                                 margin: EdgeInsets.only(top:20, left:20, right:20),
                                 decoration: BoxDecoration(
                                     border: Border(
                                         bottom: BorderSide(
                                           color: Colors.white,
                                           width: 1,
                                         ))),
                                 child: ListTile(
                                   leading: Container(
                                     padding: EdgeInsets.only(right: 12.0),
                                     decoration: BoxDecoration(
                                         border: Border(
                                             right: BorderSide(width: 1.0, color: Colors.white))),
                                     child: CircleAvatar(
                                       backgroundColor: Colors.white.withOpacity(0.5),
                                       child: Text("${index + 1}", style: TextStyle(color: Colors.white)),
                                     ),
                                   ),
                                   title: DateTime.parse(user[index]['completeTime'].toDate().toString()).isBefore(DateTime.parse(user[index]['due_date'])) && user[index]['complete'] == true ?
                                       Text('Task: ' + user[index]['task_name'],
                                       style: GoogleFonts.openSans(fontSize: 15,
                                           fontWeight: FontWeight.bold,
                                           color: Colors.white)):
                                       dateToday.isAfter(DateTime.parse(user[index]['due_date'])) && user[index]['complete'] == false ?
                                       Text('Task: ' + user[index]['task_name'] + ' (OVERDUE)',
                                           style: GoogleFonts.openSans(fontSize: 15,
                                               fontWeight: FontWeight.bold,
                                               color: Colors.white)):
                                       DateTime.parse(user[index]['completeTime'].toDate().toString()).isAfter(DateTime.parse(user[index]['due_date'])) && user[index]['complete'] == true ?
                                       Text('Task: ' + user[index]['task_name'] + ' \n(Late Completion)',
                                           style: GoogleFonts.openSans(fontSize: 15,
                                               fontWeight: FontWeight.bold,
                                               color: Colors.white)):
                                       Text('Task: ' + user[index]['task_name'],
                                           style: GoogleFonts.openSans(fontSize: 15,
                                               fontWeight: FontWeight.bold,
                                               color: Colors.white)),
                                   subtitle: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children:[
                                         SizedBox(height: 5),
                                         Text('Due on: ' + DateFormat.yMd().format(DateTime.parse(user[index]['due_date'])) + ' ' +
                                             DateFormat.jm().format(DateTime.parse(user[index]['due_date'])),
                                             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Raleway')),
                                         user[index]['complete'] == true ?
                                         Text('Status: ' + 'Completed',
                                             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Raleway'))
                                             : Text('Status: ' + 'In progress',
                                             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600 , fontFamily: 'Raleway')) ,
                                       ]),
                                   trailing: Icon(Icons.edit_outlined, size: 40,
                                       color: Colors.white),
                                   onTap: () {
                                     Navigator.push(
                                         context,
                                         MaterialPageRoute(
                                             builder: (context) =>
                                                 taskDetails(
                                                     title: user[index]['task_name'],
                                                     description: user[index]['task_desc'],
                                                     projectID: user[index]['projectID'],
                                                     taskID: user[index]['taskID'],
                                                 )));
                                   },
                                 )
                             );
                           },
                         ));
                       }
                     }
                   },
                 ),
            ],)))
    ])
    );
  }
}






