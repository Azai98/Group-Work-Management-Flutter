import 'dart:io';

import 'package:collab/profile_screens/widgets/appbar_widget.dart';
import 'package:collab/profile_screens/widgets/display_image_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collab/database.dart';
import 'package:collab/profile_screens/user/user.dart' as u;

class EditImagePage extends StatefulWidget {
  const EditImagePage({Key? key}) : super(key: key);

  @override
  _EditImagePageState createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {

  u.User user = u.User('','','','','');
  final uid = FirebaseAuth.instance.currentUser!.uid;
  // ignore: prefer_typing_uninitialized_variables
  var newImage;
  String avatarUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
              width: 330,
              child: const Text(
                "Upload a photo of yourself:",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold, fontFamily: 'Raleway'
                ),
              )),
          FutureBuilder(
              future: getUserProfileImage(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  avatarUrl = user.image;
                }
                return Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: SizedBox(
                          width: 330,
                          child: GestureDetector(
                            onTap: () async {
                              XFile? image = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);

                              if (image == null) return;
                              // ignore: await_only_futures
                              newImage = await File(image.path);
                              setState(
                                      (){});
                              if(newImage != null){
                                await DatabaseService(uid: uid).uploadProfilePicToFirebase(context, newImage);}
                              getUserProfileImage(uid);
                              setState(
                                      (){});
                            },
                              child: DisplayImage(
                                imagePath: avatarUrl,
                                onPressed: () {},
                              ),
                          ))
                  );
              }
          ),



          Padding(
              padding: EdgeInsets.only(top: 40),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 330,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async{
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Profile avatar updated!'),));
                      },
                      child: const Text(
                        'Update',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  )))
        ],
      ),
    );
  }

  getUserProfileImage(String uid) async {
    user.image = await FirebaseStorage.instance.ref().child('users/ProfilePicture/$uid').getDownloadURL();
  }

}
