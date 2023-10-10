import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'package:collab/firebase_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:permission_handler/permission_handler.dart';

class DatabaseService {
  final String uid;
  static String username ='';
  static String phone ='';
  static String bio = '';
  DatabaseService({ required this.uid });

  final CollectionReference usersData = FirebaseFirestore.instance.collection('users_data');

  Future updateUserData(String username, String phone, String bio, String email, String uid) async {
    return await usersData.doc(uid).set({
      'username' :username,
      'phone' :phone,
      'bio' :bio,
      'email' :email,
      'uid' :uid,
    });
    }

  Stream<QuerySnapshot> get users{
    return usersData.snapshots();
  }

  Future getCurrentUserData() async{
    try {
      DocumentSnapshot value = await usersData.doc(uid).get();
      username = value.get('username');
      phone = value.get('phone');
      bio = value.get('bio');
    }catch(e){
      // ignore: avoid_print
      print(e.toString());
      return null;
    }
  }

  Future uploadProfilePicToFirebase(BuildContext context, File _imageFile) async {
    String fileName = FirebaseAuth.instance.currentUser!.uid;
    Reference firebaseStorageRef =
    FirebaseStorage.instance.ref().child('users/ProfilePicture/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
          // ignore: avoid_print
          (value) => print("Done: $value"),
    );
  }

  static UploadTask? uploadFileForTask(List<File> file, String projectID, String taskID){
    try {
      for (int i = 0; i< file.length; i++) {
        final ref = FirebaseStorage.instance.ref().child('projects/$projectID/$taskID/${Path.basename(file[i].path)}');
        ref.putFile(file[i]);
        if(file[i] == file.last){
          return ref.putFile(file[i]);
        }
      }

    } on FirebaseException catch (e) {
      return null;
    }
  }

  static UploadTask? uploadBytes(String destination, Uint8List data) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putData(data);
    } on FirebaseException catch (e) {
      return null;
    }
  }

  static Future<List<String>> _getDownloadLinks(List<Reference> refs) =>
      Future.wait(refs.map((ref) => ref.getDownloadURL()).toList());

  static Future<List<FirebaseFile>> listAll(String path) async {
    final ref = FirebaseStorage.instance.ref(path);
    final result = await ref.listAll();

    final urls = await _getDownloadLinks(result.items);

    return urls
        .asMap()
        .map((index, url) {
      final ref = result.items[index];
      final name = ref.name;
      final file = FirebaseFile(ref: ref, name: name, url: url);

      return MapEntry(index, file);
    })
        .values
        .toList();
  }

  static Future<File?> downloadFile(String url, String name, Reference ref) async {
    String savingPath =  await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
    String fullPath = "$savingPath/$name";

    try {
      Response response = await Dio().get(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            receiveTimeout: 0,
          )
      );

      File file = File(fullPath);
      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
    }catch(e){
      print(e);
    }

  }
}