import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/project_screens/task_details.dart';
import 'package:flutter/material.dart';
import 'package:collab/searchservice.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LocalSearchAppBarPage extends StatefulWidget {
  const LocalSearchAppBarPage({Key? key}) : super(key: key);

  @override
  _LocalSearchAppBarPage createState() => new _LocalSearchAppBarPage();
}

class _LocalSearchAppBarPage extends State<LocalSearchAppBarPage> {
  final TextEditingController searchController = TextEditingController();
  QuerySnapshot? snapshotData;
  bool isExecuted = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Widget searchedData(){
      return ListView.builder(
        itemCount: snapshotData!.docs.length,
        itemBuilder: (BuildContext context, int index){
          return GestureDetector(
            onTap: (){
              Get.to(taskDetails(title: (snapshotData!.docs[index].data()as dynamic)['task_name'],
                                  description: (snapshotData!.docs[index].data()as dynamic)['task_desc'],
                                  taskID: (snapshotData!.docs[index].data()as dynamic)['taskID'],
                                  projectID: (snapshotData!.docs[index].data()as dynamic)['projectID'],));
            },
            child: Container(
            margin: EdgeInsets.only(top:15, left:15, right: 15, bottom: 5),
            decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.lightBlue)),
            child: ListTile(
            leading: Container(
                 padding: EdgeInsets.only(right: 12.0),
                  decoration: BoxDecoration(
                      border: Border(
                          right: BorderSide(width: 1.0, color: Colors.white24))),
                  child: CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: Text((snapshotData!.docs[index].data()as dynamic)['task_name'][0]),
                  ),
                ),
            title: Text('Task name: ' + (snapshotData!.docs[index].data() as dynamic)['task_name'],
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                SizedBox(height: 5),
                Text('Assign to: ' +(snapshotData!.docs[index].data() as dynamic)['assignee_name'],
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400)),
                Text('Due on: ' + DateFormat.yMd().format(DateTime.parse((snapshotData!.docs[index].data() as dynamic)['due_date'])) + ' ' +
                  DateFormat.jm().format(DateTime.parse((snapshotData!.docs[index].data() as dynamic)['due_date'])),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400)),
                (snapshotData!.docs[index].data() as dynamic)['complete'] == true ?
                Text('Status: ' + 'Completed',
                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400))
                : Text('Status: ' + 'In progress',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400)) ,
              ]),
            trailing: InkWell(
                child: Icon(Icons.edit, color: Colors.white, size: 40.0))
             )
            )
          );
        }
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton:
        FloatingActionButton(child: Icon(Icons.clear, color: Colors.white),
            backgroundColor: Colors.white.withOpacity(0.3), onPressed: () {
          isExecuted = false;
          setState(() {
            if(snapshotData != null) {
              snapshotData!.docs.clear();
            }
          });
        }),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          GetBuilder<DataController>(
          init: DataController(),
          builder: (val) {
            return IconButton(icon: Icon(Icons.search),
                onPressed: () {
                  val.queryData(searchController.text).then((value) {
                    snapshotData = value;
                    if(snapshotData!.docs.isEmpty){
                      Fluttertoast.showToast(
                        backgroundColor: Colors.grey,
                        msg: "Task did not found",
                        gravity: ToastGravity.CENTER,
                        fontSize: 16.0,
                      );
                    }
                    else {
                      setState(() {
                        isExecuted = true;
                      });
                    }
                  });
                });
          },
        ),
      ],
       title: TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
          hintText: 'Click here to search any task',
          hintStyle: TextStyle(color: Colors.white)),
          controller: searchController,
      )),

      body: Container(
        decoration: BoxDecoration(
        image: DecorationImage(
        image: AssetImage('assets/images/personalspaces-ui.webp'),
        fit: BoxFit.cover)),
      child: Container(
        alignment: Alignment.center,
        width: double.maxFinite,
        decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [
        Colors.black.withOpacity(0.8),
        Colors.black.withOpacity(0.7)
        ])),
      child: isExecuted ? searchedData() : Container(
        child: Center(
          child:Row(mainAxisAlignment:MainAxisAlignment.center, children:const [
            Text('Search your task', style:
            TextStyle(color: Colors.white, fontSize: 25, fontFamily: 'Raleway')),
            Icon(Icons.search_rounded, color: Colors.white, size:45)
          ],)
        ),
      )))
    );
  }
}