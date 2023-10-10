import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';
import 'package:collab/profile_screens/widgets/appbar_widget.dart';
import 'package:collab/profile_screens/user/user.dart' as u;

// This class handles the Page to edit the Phone Section of the User Profile.
class EditPhoneFormPage extends StatefulWidget {
  const EditPhoneFormPage({Key? key}) : super(key: key);
  @override
  EditPhoneFormPageState createState() {
    return EditPhoneFormPageState();
  }
}

class EditPhoneFormPageState extends State<EditPhoneFormPage> {
  u.User user = u.User("","","","","");
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  //var user = UserData.myUser;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void updateUserValue(String phone) {
    String formattedPhoneNumber = "(" +
        phone.substring(0, 3) +
        ") " +
        phone.substring(3, 6) +
        "-" +
        phone.substring(6, phone.length);
    user.phone = formattedPhoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: Form(
          key: _formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                    width: 320,
                    child: const Text(
                      "What's Your Phone Number?",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: 'Raleway'),
                    )),
                Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: SizedBox(
                        height: 100,
                        width: 320,
                        child: TextFormField(
                          // Handles Form Validation
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            } else if (isAlpha(value)) {
                              return 'Only Numbers Please, without dash';
                            } else if (value.length != 10 && value.length != 11) {
                              return 'Please enter a VALID phone number';
                            }
                            return null;
                          },
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Your Phone Number',
                          ),
                        ))),
                Padding(
                    padding: EdgeInsets.only(top: 150),
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: 320,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async{
                              user.phone = phoneController.text;
                              // Validate returns true if the form is valid, or false otherwise.
                              setState(() {});
                              if (_formKey.currentState!.validate() &&
                                  isNumeric(phoneController.text)) {
                                updateUserValue(user.phone);
                                final user1 = FirebaseAuth.instance.currentUser!;
                                final uid = user1.uid;
                                await FirebaseFirestore.instance
                                    .collection('users_data')
                                    .doc(uid)
                                    .update(user.updatePhone());
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Phone number updated!'),));
                              }
                            },
                            child: const Text(
                              'Update',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        )))
              ]),
        ));
  }
}
