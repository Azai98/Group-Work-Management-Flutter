import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:collab/constants.dart';

class RoundedInputField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  
  const RoundedInputField({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<RoundedInputField> createState() => _RoundedInputField();
}

class _RoundedInputField extends State<RoundedInputField> {
  IconData? get icon => Icons.mail;

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
            return 'Please enter your email';
          }
          if (!EmailValidator.validate(value)){
            return 'Please enter a valid email';
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
          labelText: "Email",
        ),
      ),
    );
  }
}

