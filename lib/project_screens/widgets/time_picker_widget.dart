import 'package:collab/project_screens/widgets/button_widget.dart';
import 'package:collab/project_screens/widgets/datetime_extensions.dart';
import 'package:flutter/material.dart';

class TimePickerWidget extends StatefulWidget {
  TimeOfDay? t;
  TimePickerWidget({Key? key, required this.t}) : super(key:key);

  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();

  getTime(){
    return _TimePickerWidgetState.time;
  }

}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  static TimeOfDay? time;

  @override
  void dispose(){
    super.dispose();
    time = null;
  }

  String getText() {
    if(widget.t != null) {
      time = widget.t;
    }
    if (time == null) {
      return 'Select Time';
    } else {
      final hours = time!.hour.toString().padLeft(2, '0');
      final minutes = time!.minute.toString().padLeft(2, '0');

      return '$hours:$minutes';
    }
  }

  @override
  Widget build(BuildContext context) => ButtonHeaderWidget(
        title: 'Time',
        text: getText(),
        onClicked: () => pickTime(context),
      );

  Future pickTime(BuildContext context) async {
    final initialTime = TimeOfDay(hour: 9, minute: 0);
    final newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (newTime == null) return;

    setState(() {time = newTime; widget.t = null;});
  }
}
