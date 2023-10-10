import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/profile_screens/widgets/appbar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collab/profile_screens/user/user.dart' as u;

// This class handles the Page to edit the Name Section of the User Profile.
class EditNameFormPage extends StatefulWidget {
  const EditNameFormPage({Key? key}) : super(key: key);

  @override
  EditNameFormPageState createState() {
    return EditNameFormPageState();
  }
}

class EditNameFormPageState extends State<EditNameFormPage> {
  u.User user = u.User("","","","","");
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final secondNameController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    super.dispose();
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
                  width: 330,
                  child: const Text(
                    "What's Your Name?",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold, fontFamily: 'Raleway'
                    ),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 40, 16, 0),
                      child: SizedBox(
                          height: 100,
                          width: 150,
                          child: TextFormField(
                            // Handles Form Validation for First Name
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              else if (!value.contains(RegExp(r'[a-zA-Z ]'))) {
                                return 'Only Letters Please';
                              }
                              return null;
                            },
                            decoration:
                                InputDecoration(labelText: 'First Name'),
                            controller: firstNameController,
                          ))),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 40, 16, 0),
                      child: SizedBox(
                          height: 100,
                          width: 150,
                          child: TextFormField(
                            // Handles Form Validation for Last Name
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              else if (!value.contains(RegExp(r'[a-zA-Z ]'))) {
                                return 'Only Letters Please';
                              }
                              return null;
                            },
                            decoration:
                                const InputDecoration(labelText: 'Last Name'),
                            controller: secondNameController,
                          )))
                ],
              ),
              Padding(
                  padding: EdgeInsets.only(top: 150),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: 330,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async{
                            firstNameController.text = firstNameController.text.trim();
                            secondNameController.text = secondNameController.text.trim();

                            user.username = firstNameController.text + " " + secondNameController.text;
                            setState(() {});
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formKey.currentState!.validate()) {
                              final user1 = FirebaseAuth.instance.currentUser!;
                              final uid = user1.uid;
                              await FirebaseFirestore.instance
                                  .collection('users_data')
                                  .doc(uid)
                                  .update(user.updateName());
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: const Text('Username updated!'),));
                            }
                            setState(() {});
                          },
                          child: const Text(
                            'Update',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      )))
            ],
          ),
        ));
  }
}
