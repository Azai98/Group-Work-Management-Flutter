import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/constants.dart';
import 'package:collab/personal_spaces/model/event.dart';
import 'package:collab/project_screens/task_details.dart';
import 'package:collab/widgets/provider_widgets.dart';
import 'package:firebase_helpers/firebase_helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class calendarSchedule extends StatefulWidget {
  const calendarSchedule({Key? key}) : super(key: key);

  @override
  _calendarSchedule createState() => _calendarSchedule();
}

class _calendarSchedule extends State<calendarSchedule> {
  late CalendarController _controller;
  late Map<DateTime, List<dynamic>> _events;
  late List<dynamic> _selectedEvents;
  DateTime dateToday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day) ;
  final eventDBS = DatabaseService<EventModel>(
    'users_data', getPath(),
    fromDS: (id,data) => EventModel.fromDS(id, data!),
    toMap:(event) => event.toMap(),);

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _events = {};
    _selectedEvents = [];
  }

  Map<DateTime, List<dynamic>> _groupEvents(List<EventModel> events) {
    Map<DateTime, List<dynamic>> data = {};
    events.forEach((event) {
      DateTime date =
      DateTime.utc(event.due!.year, event.due!.month, event.due!.day, 12);
      if (data[date] == null) data[date] = [];
      data[date]!.add(event);
    });
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Calendar & Schedule", style: TextStyle(
              fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: true,
        ),
        body: Stack(
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
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter, colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.7)
                    ])),
              ),
              Container(
                  padding: EdgeInsets.only(top: 70),
                  child: StreamBuilder<List<EventModel>>(
                      stream: eventDBS.streamList(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          print(snapshot);
                          print("no data");
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        else {
                          List<EventModel> allEvents = snapshot.data;
                          _events = _groupEvents(allEvents);
                          DateTime selectedDate = _controller.selectedDay;
                          _selectedEvents = _events[selectedDate] ?? [];
                          return SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                TableCalendar(
                                  events: _events,
                                  initialCalendarFormat: CalendarFormat.month,
                                  daysOfWeekStyle: DaysOfWeekStyle(
                                    weekdayStyle: TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.white),
                                    weekendStyle: TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.orangeAccent),
                                  ),
                                  calendarStyle: CalendarStyle(
                                      canEventMarkersOverflow: true,
                                      todayColor: Colors.orange,
                                      eventDayStyle: TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.red),
                                      markersColor: Colors.red,
                                      outsideStyle: TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.white70),
                                      weekdayStyle: TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.white),
                                      weekendStyle: TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.orangeAccent),
                                      outsideWeekendStyle: TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.orangeAccent),
                                      selectedColor: Theme
                                          .of(context)
                                          .primaryColor,
                                      todayStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                          color: Colors.white)),
                                  headerStyle: HeaderStyle(
                                    titleTextStyle: TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.white),
                                    centerHeaderTitle: true,
                                    formatButtonDecoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    formatButtonTextStyle: TextStyle(
                                        color: Colors.white),
                                    formatButtonShowsNext: false,
                                    leftChevronIcon: Icon(
                                        Icons.chevron_left, color: Colors.white),
                                    rightChevronIcon: Icon(
                                        Icons.chevron_right, color: Colors.white),
                                  ),
                                  startingDayOfWeek: StartingDayOfWeek.monday,
                                  onDaySelected: (date, events, holiday) {
                                    setState(() {
                                      _selectedEvents = events;
                                    });
                                  },
                                  builders: CalendarBuilders(
                                    selectedDayBuilder: (context, date, events) =>
                                        Container(
                                            margin: const EdgeInsets.all(4.0),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: Theme
                                                    .of(context)
                                                    .primaryColor,
                                                borderRadius: BorderRadius.circular(
                                                    10.0)),
                                            child: Text(
                                              date.day.toString(),
                                              style: TextStyle(color: Colors.white),
                                            )),
                                    todayDayBuilder: (context, date, events) =>
                                        Container(
                                            margin: const EdgeInsets.all(4.0),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: Colors.orange,
                                                borderRadius: BorderRadius.circular(
                                                    10.0)),
                                            child: Text(
                                              date.day.toString(),
                                              style: TextStyle(color: Colors.white),
                                            )),
                                  ),
                                  calendarController: _controller,
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                                    child: selectedDate == null ? Text(
                                      DateFormat('EEEE, dd MMMM, yyyy').format(DateTime.now()),
                                      style: TextStyle(color: Colors.white, fontFamily: 'Raleway', fontSize: 20),
                                    ):
                                    Text(
                                      DateFormat('EEEE, dd MMMM, yyyy').format(selectedDate),
                                      style: TextStyle(color: Colors.white, fontFamily: 'Raleway', fontSize: 20),
                                    )
                                ),
                                ..._selectedEvents.map((event) =>
                                    Container(
                                        margin: EdgeInsets.only(top:20, left:15, right:15),
                                        decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.grey)),
                                        child: ListTile(
                                          title: event.completeTime.isBefore(event.due) && event.status == true ?
                                          Text('Task: ' + event.name,
                                              style: TextStyle(fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,  fontFamily: 'Raleway')):
                                          dateToday.isAfter(event.due) && event.status == false ?
                                          Text('Task: ' + event.name + ' (OVERDUE)',
                                              style: TextStyle(fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white, fontFamily: 'Raleway')) :
                                          event.completeTime.isAfter(event.due) && event.status == true ?
                                          Text('Task: ' + event.name + ' (Late Completion)',
                                              style: TextStyle(fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white, fontFamily: 'Raleway')) :
                                          Text('Task: ' + event.name,
                                              style: TextStyle(fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,  fontFamily: 'Raleway')),
                                          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                                            SizedBox(height: 3),
                                            Text('Due on: ' +
                                                DateFormat.jm().format(event.due).toString(),
                                                style: TextStyle(fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,  fontFamily: 'Raleway')),
                                            event.status == false ?
                                            Text('Status: Not complete yet',
                                                style: TextStyle(fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,  fontFamily: 'Raleway')):
                                            Text('Status: Completed',
                                                style: TextStyle(fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.greenAccent,  fontFamily: 'Raleway'))
                                          ]),

                                          trailing: Icon(Icons.arrow_right_sharp, size: 50,
                                              color: Colors.white),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        taskDetails(
                                                            title: event.name,
                                                            description: event.desc,
                                                            projectID: event.projectID,
                                                            taskID: event.taskID
                                                        )));
                                          },
                                        )
                                    )),
                                _selectedEvents.isEmpty ?
                                Container(
                                    margin: EdgeInsets.all(20),
                                    child:Text(
                                        'You have no task due by today! cheers!',
                                        style: TextStyle(fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'Raleway')))
                                    : Container()
                              ],
                            ),
                          );
                        }
                      })
              )
            ])
    );
  }

}