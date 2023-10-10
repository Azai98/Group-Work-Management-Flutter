import 'package:collab/project_screens/widgets/button_widget.dart';
import 'package:collab/project_screens/widgets/datetime_extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatefulWidget {
  DateTime? dt;
  DatePickerWidget({Key? key, required this.dt}) : super(key: key);

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();

  getDate(){
    return _DatePickerWidgetState.date;
  }

}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  static DateTime? date;

  @override
  void dispose(){
    super.dispose();
    date = null;
  }

  String getText() {
    if(widget.dt != null){
      date = widget.dt;
    }
    if (date == null) {
      return 'Select Date';
    } else {
      return DateFormat('MM/dd/yyyy').format(date!);
      // return '${date.month}/${date.day}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) => ButtonHeaderWidget(
        title: 'Date',
        text: getText(),
        onClicked: () => pickDate(context),
      );

  Future pickDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (newDate == null) return;

    setState((){ date = newDate; widget.dt = null;});
  }

}
