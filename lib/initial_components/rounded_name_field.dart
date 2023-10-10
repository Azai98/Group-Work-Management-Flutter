import 'package:flutter/material.dart';
import 'package:collab/constants.dart';
import 'package:string_validator/string_validator.dart';

class RoundedNameField extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const RoundedNameField({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<RoundedNameField> createState() => _RoundedNameField();
}

class _RoundedNameField extends State<RoundedNameField> {
  IconData? get icon => Icons.person;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 325,
      padding: EdgeInsets.fromLTRB(10,2,10,2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.red)
      ),
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your username';
          } else if (!isAlpha(value)) {
            return 'Only Letters Please';
          }
          return null;
        },
        keyboardType: TextInputType.emailAddress,
        onChanged: widget.onChanged,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: kPrimaryColor,
          ),
          border: InputBorder.none,
          labelText: "Username",
        ),
      ),
    );
  }
}