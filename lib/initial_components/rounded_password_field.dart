import 'package:flutter/material.dart';
import 'package:collab/constants.dart';

class RoundedPasswordField extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const RoundedPasswordField({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<RoundedPasswordField> createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {

    void _toggle() {
      setState(() {
        _passwordVisible = !_passwordVisible;
      });
    }
    return Container(
      width: 325,
      padding: EdgeInsets.fromLTRB(10,2,10,2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.red)
      ),
      child: TextFormField(
        obscureText: !_passwordVisible,
        validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
        onChanged: widget.onChanged,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          icon: Icon(
            Icons.lock,
            color: kPrimaryColor,
          ),
          suffixIcon: IconButton(
            icon:Icon(
            _passwordVisible ?
            Icons.visibility
            : Icons.visibility_off,
            color: kPrimaryColor,
          ),
            onPressed: (){_toggle();},
          ),
          border: InputBorder.none,
          labelText: "Password",
        ),
      ),
    );
  }
}

