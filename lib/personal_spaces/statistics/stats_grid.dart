import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatsGrid extends StatefulWidget {
  final String projectID;
  const StatsGrid({Key? key, required this.projectID}) : super(key: key);

  @override
  _StatsGrid createState() => _StatsGrid();
}

class _StatsGrid extends State<StatsGrid> {
  int totalCollaborator = 0, completedTask = 0, progressTask = 0, overDue = 0, remainingDay = 0;
  bool isStart = true;

  @override
  void initState(){
    super.initState();
    getProjectInfo();
    getTaskOverall();
  }

  void getProjectInfo() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DateTime? projectEnd; DateTime? projectStart;
    DateTime time = DateTime.now();

    await db
        .collection('projects')
        .doc(widget.projectID)
        .get()
        .then((value) {
      setState(() {
        totalCollaborator = value.data()?["members"].length;
        projectEnd =  DateTime.parse(value['project end']);
        projectStart =  DateTime.parse(value['project start']);
      });
    });

    int daysBetween(DateTime from, DateTime to) {
      from = DateTime(from.year, from.month, from.day);
      to = DateTime(to.year, to.month, to.day);
      return (to.difference(from).inHours / 24).round();
    }

    if(projectStart!.isAfter(time)){
      isStart = false;
    }
    else {
      remainingDay = daysBetween(time, projectEnd!);
    }
  }

  void getTaskOverall() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DateTime time = DateTime.now();

    QuerySnapshot querySnapshot = await db.collection('projects').doc(widget.projectID).collection('tasks').get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    //completeTask & progressing task
    for(int i = 0; i<allData.length; i ++){
      if((allData[i] as dynamic)['complete'] == true){
        setState(() {
          completedTask++;
        });
      }
      else{
        setState(() {
          progressTask++;
        });
      }
    }

    //overDue
    for(int i = 0; i<allData.length; i++){
      if((allData[i] as dynamic)['complete'] == false) {
        if (time.isAfter(DateTime.parse((allData[i] as dynamic)['due_date']))) {
          overDue++;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,
      child: Column(
        children: <Widget>[
          Flexible(
            child: Row(
              children: <Widget>[
                _buildTopStatCard('Total Collaborator', totalCollaborator.toString() +  ' Users', Colors.orange , "assets/images/collaborator.png"),
                isStart == false ?
                _buildTopStatCard('Time Remaining', 'Not start yet ', Colors.red, 'assets/images/time.png'):
                remainingDay.isNegative ?
                _buildTopStatCard('Time Remaining', 'Overdue ' + (remainingDay*-1).toString() + 'days', Colors.red, 'assets/images/time.png',):
                _buildTopStatCard('Time Remaining', remainingDay.toString() +  ' Days', Colors.red, 'assets/images/time.png')
              ],
            ),
          ),
          Flexible(
            child: Row(
              children: <Widget>[
                _buildBottomStatCard('Completed', completedTask.toString() + ' task', Colors.green, 'assets/images/archive.png'),
                _buildBottomStatCard('In Progress', progressTask.toString() + ' task', Colors.lightBlue, 'assets/images/inprogress.png'),
                _buildBottomStatCard('Overdue', overDue.toString() + ' task', Colors.purple, "assets/images/overdue.png"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded _buildBottomStatCard(String title, String count, MaterialColor color, String image) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(children: [
              Image.asset(
              image,
              width: 20,
            ),
            SizedBox(width: 5),
            Text(
                count,
                softWrap: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
             )
            ]),
          ],
        ),
      ),
    );
  }

  Expanded _buildTopStatCard(String title, String count, MaterialColor color, String image) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(children: [
              Image.asset(
                image,
                width: 20,
              ),
              SizedBox(width: 5),
              Text(
                count,
                softWrap: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                ),
              )
            ]),
          ],
        ),
      ),
    );
  }
}
