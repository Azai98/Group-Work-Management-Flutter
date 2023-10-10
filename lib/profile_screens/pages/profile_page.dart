import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/constants.dart';
import 'package:collab/profile_screens/pages/edit_description.dart';
import 'package:collab/profile_screens/pages/edit_image.dart';
import 'package:collab/profile_screens/pages/edit_name.dart';
import 'package:collab/profile_screens/pages/edit_phone.dart';
import 'package:collab/profile_screens/widgets/display_image_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:collab/profile_screens/user/user.dart' as u;


// This class handles the Page to dispaly the user's info on the "Edit Profile" Screen
class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  u.User user = u.User("","","","","");
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userPhoneController = TextEditingController();
  final TextEditingController _userBioController = TextEditingController();
  String avatarUrl = '';

  @override
  Widget build(BuildContext context) {
    final user1 = FirebaseAuth.instance.currentUser!;
    // ignore: unused_local_variable
    final uid = user1.uid;
    // ignore: unused_local_variable
    CollectionReference usersdata = FirebaseFirestore.instance.collection('users_data');

    // ignore: unused_local_variable
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          FutureBuilder(
            future: _getProfileData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return buildUserInfoDisplay(context, snapshot);
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
    );
  }

  // Widget builds the display item with the proper formatting to display the user's info
  Widget buildUserInfoDisplay(context, snapshot) {
    final thisuser = FirebaseAuth.instance.currentUser!;
    final uid = thisuser.uid;


    return Padding(
        padding: EdgeInsets.only(top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:<Widget> [
            FutureBuilder(
                future: getUserProfileImage(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                      avatarUrl = user.image;
                  }
                  return InkWell(
                      onTap: () {
                        navigateSecondPage(EditImagePage());
                      },
                      child: DisplayImage(
                        imagePath: avatarUrl,
                        onPressed: () {},
                      )
                  );
                }
            ),
            Container(
                margin: const EdgeInsets.only(left: 20,bottom: 20, top: 20),
                width: 350,
                height: 50,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                          color: Colors.white70,
                          width: 1,
                        ))),
                child: Row(children: [
                  Icon(
                    Icons.email,
                    color: Colors.white,
                  ),
                  Flexible(
                      child:Container(
                      width: 240,
                      margin: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        // ignore: unnecessary_string_interpolations
                        "${thisuser.email ?? 'Anonymous'}",
                        style: TextStyle(fontSize: 15, height: 1.4,fontFamily: 'Raleway',fontWeight: FontWeight.bold,  color: Colors.white),
                      )),)
                ])),
            FutureBuilder(
                future: _getProfileData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    _userNameController.text = user.username;
                  }
                  return Container(
                    margin: const EdgeInsets.only(left: 20,bottom: 20),
                    width: 350,
                    height: 50,
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                              color: Colors.white70,
                              width: 1,
                            ))),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        Container(
                          width: 200,
                          margin: const EdgeInsets.only(left: 20.0),
                          child: Text(
                            // ignore: unnecessary_string_interpolations
                            "${_userNameController.text}", softWrap: true,
                            style: TextStyle(fontSize: 15, height: 1.4,fontFamily: 'Raleway',fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),

                        Expanded(
                          child: TextButton.icon(
                              style: TextButton.styleFrom(
                                primary: Colors.blueGrey,
                                alignment: Alignment.centerRight,
                              ),
                          icon: Icon(Icons.keyboard_arrow_right, color: Colors.white),
                          label: Text('editnow', style: TextStyle(color: Colors.white70)),
                          onPressed: () {
                            navigateSecondPage(EditNameFormPage());
                          },
                        )),
                      ],
                    ),
                  );
                }
            ),
            FutureBuilder(
                future: _getProfileData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    _userPhoneController.text = user.phone;
                  }
                  return Container(
                    margin: const EdgeInsets.only(left: 20,bottom: 20),
                    width: 350,
                    height: 50,
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                              color: Colors.white70,
                              width: 1,
                            ))),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.phone,
                          color: Colors.white,
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20.0),
                          child: Text(
                            // ignore: unnecessary_string_interpolations
                            "${_userPhoneController.text}",
                            style: TextStyle(fontSize: 15, height: 1.4,fontFamily: 'Raleway',fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        Expanded(
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                primary: Colors.blueGrey,
                                alignment: Alignment.centerRight,
                              ),
                              icon: Icon(Icons.keyboard_arrow_right, color: Colors.white),
                              label: Text('editnow', style: TextStyle(color: Colors.white70)),
                              onPressed: () {
                                navigateSecondPage(EditPhoneFormPage());
                              },
                            )),
                      ],
                    ),
                  );
                }
            ),
            FutureBuilder(
                future: _getProfileData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    _userBioController.text = user.bio;
                  }
                  return Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.only(left: 20,bottom: 20),
                    width: 350,
                    height: 150,
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                              color: Colors.white70,
                              width: 1,
                            ))),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.work,
                          color: Colors.white,
                        ),
                        Container(
                            width: 200,
                          margin: const EdgeInsets.only(left: 20.0),
                          child: Text(
                            // ignore: unnecessary_string_interpolations
                            "${_userBioController.text}",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 15, height: 1.4,fontFamily: 'Raleway',fontWeight: FontWeight.bold,  color: Colors.white),
                          ),
                        ),
                        Expanded(
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                primary: Colors.blueGrey,
                                alignment: Alignment.centerRight,
                              ),
                              icon: Icon(Icons.keyboard_arrow_right, color: Colors.white),
                              label: Text('editnow', style: TextStyle(color: Colors.white70)),
                              onPressed: () {
                                navigateSecondPage(EditDescriptionFormPage());
                              },
                            )),
                      ],
                    ),
                  );
                }
            ),
          ],
        )
    );
  }

  _getProfileData() async{
    final user1 = FirebaseAuth.instance.currentUser!;
    final uid = user1.uid;
    await FirebaseFirestore.instance
        .collection('users_data')
        .doc(uid)
        .get().then((result) {
      user.username = result.data()!['username'];
      user.phone = result.data()!['phone'];
      user.bio = result.data()!['bio'];
    });
  }

  getUserProfileImage(String uid) async {
    user.image = await FirebaseStorage.instance.ref().child('users/ProfilePicture/$uid').getDownloadURL();
  }

  // Refrshes the Page after updating user info.
  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  // Handles navigation and prompts refresh.
  void navigateSecondPage(Widget editForm) {
    Route route = MaterialPageRoute(builder: (context) => editForm);
    Navigator.push(context, route).then(onGoBack);
  }
}
