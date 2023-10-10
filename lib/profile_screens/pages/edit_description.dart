import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/profile_screens/widgets/appbar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collab/profile_screens/user/user.dart' as u;


// This class handles the Page to edit the About Me Section of the User Profile.
class EditDescriptionFormPage extends StatefulWidget {
  const EditDescriptionFormPage({Key? key}) : super(key: key);

  @override
  _EditDescriptionFormPageState createState() =>
      _EditDescriptionFormPageState();
}

class _EditDescriptionFormPageState extends State<EditDescriptionFormPage> {
  u.User user = u.User("","","","","");
  final _formKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();
  //var user = UserData.myUser;

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

 /* void updateUserValue(String description) {
    user.aboutMeDescription = description;
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: buildAppBar(context),
        body: Form(
          key: _formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                    width: 350,
                    child: const Text(
                      "Describe yourself",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: 'Raleway'),
                    )),
                Padding(
                    padding: EdgeInsets.all(20),
                    child: SizedBox(
                        height: 250,
                        width: 350,
                        child: TextFormField(
                          // Handles Form Validation
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length > 200) {
                              return 'Please describe yourself but keep it under 200 characters.';
                            }
                            return null;
                          },
                          controller: descriptionController,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                              alignLabelWithHint: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 15, 10, 100),
                              hintMaxLines: 3,
                              hintText:
                                  'Write a little bit about yourself. What is your position? What is your characteristics? Are you a collaborator? Etc.'),
                        ))),
                Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: 350,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async{
                              user.bio = descriptionController.text;
                              setState(() {});
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                final user1 = FirebaseAuth.instance.currentUser!;
                                final uid = user1.uid;
                                await FirebaseFirestore.instance
                                    .collection('users_data')
                                    .doc(uid)
                                    .update(user.updateBio());
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Bio updated!'),));
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
