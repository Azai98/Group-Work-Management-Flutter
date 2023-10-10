import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/personal_spaces/statistics/data.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class statChart extends StatefulWidget {
  final String projectID;
  const statChart({Key? key, required this.projectID}) : super(key: key);

  @override
  _statChart createState() => _statChart();
}

class _statChart extends State<statChart> {
  List<Task> seriesList = []; int upper = 0;
  List<DateTime> mydata = [];
  String currentWeek = '';
  int mon = 0, tue = 0, wed = 0, thu = 0, fri = 0, sat = 0, sun = 0;
  DateTime date = DateTime.now(); late DateTime monday; late DateTime tuesday; late DateTime wednesday; late DateTime thursday; late DateTime friday;
  late DateTime saturday; late DateTime sunday;

  @override
  void initState(){
    super.initState();
    setWeekdays();
    getProjectStatistics();
  }

  setWeekdays(){
    int today = date.weekday;
    switch(today){
      case 1:
        monday = DateTime(date.year, date.month, date.day);
        tuesday = DateTime(date.year, date.month, date.day + 1);
        wednesday = DateTime(date.year, date.month, date.day + 2);
        thursday = DateTime(date.year, date.month, date.day + 3);
        friday = DateTime(date.year, date.month, date.day + 4);
        saturday = DateTime(date.year, date.month, date.day + 5);
        sunday = DateTime(date.year, date.month, date.day + 6);
        break;

      case 2:
        monday = DateTime(date.year, date.month, date.day - 1);
        tuesday = DateTime(date.year, date.month, date.day);
        wednesday = DateTime(date.year, date.month, date.day + 1);
        thursday = DateTime(date.year, date.month, date.day + 2);
        friday = DateTime(date.year, date.month, date.day + 3);
        saturday = DateTime(date.year, date.month, date.day + 4);
        sunday = DateTime(date.year, date.month, date.day + 5);
        break;

      case 3:
        monday = DateTime(date.year, date.month, date.day - 2);
        tuesday = DateTime(date.year, date.month, date.day - 1);
        wednesday = DateTime(date.year, date.month, date.day);
        thursday = DateTime(date.year, date.month, date.day + 1);
        friday = DateTime(date.year, date.month, date.day + 2);
        saturday = DateTime(date.year, date.month, date.day + 3);
        sunday = DateTime(date.year, date.month, date.day + 4);
        break;

      case 4:
        monday = DateTime(date.year, date.month, date.day - 3);
        tuesday = DateTime(date.year, date.month, date.day - 2);
        wednesday = DateTime(date.year, date.month, date.day - 1);
        thursday = DateTime(date.year, date.month, date.day);
        friday = DateTime(date.year, date.month, date.day + 1);
        saturday = DateTime(date.year, date.month, date.day + 2);
        sunday = DateTime(date.year, date.month, date.day + 3);
        break;

      case 5:
        monday = DateTime(date.year, date.month, date.day - 4);
        tuesday = DateTime(date.year, date.month, date.day - 3);
        wednesday = DateTime(date.year, date.month, date.day - 2);
        thursday = DateTime(date.year, date.month, date.day - 1);
        friday = DateTime(date.year, date.month, date.day);
        saturday = DateTime(date.year, date.month, date.day + 1);
        sunday = DateTime(date.year, date.month, date.day + 2);
        break;

      case 6:
        monday = DateTime(date.year, date.month, date.day - 5);
        tuesday = DateTime(date.year, date.month, date.day - 4);
        wednesday = DateTime(date.year, date.month, date.day - 3);
        thursday = DateTime(date.year, date.month, date.day - 2);
        friday = DateTime(date.year, date.month, date.day - 1);
        saturday = DateTime(date.year, date.month, date.day);
        sunday = DateTime(date.year, date.month, date.day + 1);
        break;

      case 7:
        monday = DateTime(date.year, date.month, date.day - 6);
        tuesday = DateTime(date.year, date.month, date.day - 5);
        wednesday = DateTime(date.year, date.month, date.day - 4);
        thursday = DateTime(date.year, date.month, date.day - 3);
        friday = DateTime(date.year, date.month, date.day - 2);
        saturday = DateTime(date.year, date.month, date.day - 1);
        sunday = DateTime(date.year, date.month, date.day);
        break;
    }
  }

  /// Create one series with sample hard coded data.
  List<charts.Series<Task, DateTime>> _createSampleData() {
    final List<Task> data = seriesList;

    return <charts.Series<Task, DateTime>>[
      charts.Series<Task, DateTime>(
        seriesColor: charts.ColorUtil.fromDartColor(Colors.blue),
        id: 'Tasks',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Task task, _) => task.completeTime,
        measureFn: (Task task, _) => task.taskCompletedPerday,
        data: data,
        labelAccessorFn: (Task task, _) => '${task.taskCompletedPerday}',
      )
    ];
  }

  void getProjectStatistics() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    List<int> temp = [];
    QuerySnapshot querySnapshot = await db.collection('projects').doc(widget.projectID).collection('tasks').get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    DateTime now = DateTime.now();
    DateTime currentDate = DateTime(now.year, now.month, now.day);
    int currentDay = currentDate.weekday;
    DateTime currentWeekFirstDay = currentDate.subtract(Duration(days: currentDay-1));
    DateTime dayAfternewWeek = currentDate.add(Duration(days: DateTime.daysPerWeek - currentDate.weekday + 1));
    DateTime lastDayWeek = currentDate.add(Duration(days: DateTime.daysPerWeek - currentDate.weekday));
    currentWeek = DateFormat.Md().format(currentWeekFirstDay) + '-' + DateFormat.Md().format(lastDayWeek);
    for(int i = 0; i<allData.length; i++){
      if(DateTime.parse((allData[i] as dynamic)['completeTime'].toDate().toString()).isAfter(currentWeekFirstDay)
        && DateTime.parse((allData[i] as dynamic)['completeTime'].toDate().toString()).isBefore(dayAfternewWeek)) {
        if ((allData[i] as dynamic)['complete'] == true) {
          int tempDay = DateTime
              .parse(
              (allData[i] as dynamic)['completeTime'].toDate().toString())
              .weekday;
          switch (tempDay) {
            case 1:
              mon++;
              break;
            case 2:
              tue++;
              break;
            case 3:
              wed++;
              break;
            case 4:
              thu++;
              break;
            case 5:
              fri++;
              break;
            case 6:
              sat++;
              break;
            case 7:
              sun++;
              break;
          }
        }
      }
        temp.add(mon); temp.add(tue); temp.add(wed); temp.add(thu); temp.add(fri); temp.add(sat); temp.add(sun);
        if (temp != null && temp.isNotEmpty) {
          dynamic max = temp.first;
          temp.forEach((e) {
            if (e > max) max = e;
          });
          upper = max;
        }

        setState(() {
          //set of data
          seriesList.add(Task(monday, mon));
          seriesList.add(Task(tuesday, tue));
          seriesList.add(Task(wednesday, wed));
          seriesList.add(Task(thursday, thu));
          seriesList.add(Task(friday, fri));
          seriesList.add(Task(saturday, sat));
          seriesList.add(Task(sunday, sun));
        });
    }
  }

  @override
  Widget build(BuildContext context) {
     return
       StreamBuilder<QuerySnapshot>(
         stream: FirebaseFirestore.instance.collection('projects').doc(widget.projectID).collection('tasks').snapshots(),
         builder: (context, snapshot) {
           if (!snapshot.hasData) {
             return LinearProgressIndicator();
           } else {
             return _buildChart(context);
           }
         },
       );
  }

  Widget _buildChart(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.only(left:15, right:15, bottom:10, top:10),
      child: Container(
        margin: EdgeInsets.all(8.0),
        height: 350,
        width: double.infinity,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Text('Task completed per Day ($currentWeek)', style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: charts.TimeSeriesChart(_createSampleData(),
                  primaryMeasureAxis:  charts.NumericAxisSpec(
                    showAxisLine: true,
                    tickProviderSpec:  charts.BasicNumericTickProviderSpec(
                      desiredTickCount: upper + 3,
                    ),
                      renderSpec: charts.GridlineRendererSpec(
                        // Tick and Label styling here.
                          labelStyle: charts.TextStyleSpec(
                              fontSize: 15, // size in Pts.
                              color: charts.MaterialPalette.black),
                          // Change the line colors to match text color.
                          lineStyle: charts.LineStyleSpec(
                              color: charts.MaterialPalette.gray.shadeDefault, dashPattern: const [5, 5]),
                          axisLineStyle: charts.LineStyleSpec(
                              color: charts.MaterialPalette.deepOrange.shadeDefault)),
                  ),
                  defaultRenderer: charts.BarRendererConfig<DateTime>(
                      cornerStrategy: charts.ConstCornerStrategy(30),
                  ),
                  domainAxis: charts.DateTimeAxisSpec(
                    tickProviderSpec: charts.StaticDateTimeTickProviderSpec(
                      <charts.TickSpec<DateTime>>[
                        charts.TickSpec<DateTime>(monday),
                        charts.TickSpec<DateTime>(tuesday),
                        charts.TickSpec<DateTime>(wednesday),
                        charts.TickSpec<DateTime>(thursday),
                        charts.TickSpec<DateTime>(friday),
                        charts.TickSpec<DateTime>(saturday),
                        charts.TickSpec<DateTime>(sunday),
                      ],
                    ),
                    renderSpec: charts.SmallTickRendererSpec(
                        // Tick and Label styling here.
                          labelStyle: charts.TextStyleSpec(
                              fontSize: 15, // size in Pts.
                              color: charts.MaterialPalette.black),
                          // Change the line colors to match text color.
                          lineStyle: charts.LineStyleSpec(
                              color: charts.MaterialPalette.deepOrange.shadeDefault)),
                    tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
                      day: charts.TimeFormatterSpec(
                        format: 'EEE',
                        transitionFormat: 'EEE',
                      ),
                    ),
                  ),
                  animate: true,
                  animationDuration: Duration(seconds:1),
                  behaviors: [
                    charts.ChartTitle('Days (Current week)',
                        behaviorPosition: charts.BehaviorPosition.bottom,
                        titleOutsideJustification: charts.OutsideJustification.middleDrawArea,
                        titleStyleSpec: charts.TextStyleSpec(fontSize: 16, color: charts.MaterialPalette.black, fontFamily: 'Raleway')),
                    charts.ChartTitle('Number of tasks',
                        behaviorPosition: charts.BehaviorPosition.start,
                        titleOutsideJustification: charts.OutsideJustification.middleDrawArea,
                        titleStyleSpec: charts.TextStyleSpec(fontSize: 16, color: charts.MaterialPalette.black, fontFamily: 'Raleway')),
                  ],
              ),
              )],
          ),
        ),
      ),
    );
  }
}