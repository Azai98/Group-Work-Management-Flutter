import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collab/constants.dart';
import 'package:get/get.dart';


class DataController extends GetxController {
  Future getData() async {
    final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot =
    await firebaseFirestore.collection('users_data').doc(getPath()).collection('event_data').get();
    return snapshot.docs;
  }

  Future<QuerySnapshot> queryData(String queryString) async {
    return FirebaseFirestore.instance
        .collection('users_data')
        .doc(getPath())
        .collection('event_data')
        .where('task_name', isGreaterThanOrEqualTo: queryString)
        .where('task_name', isLessThan: getNextChar(queryString))
        .get();
  }

  String getNextChar(String s) {
    var lastChar = s[s.length - 1];
    var nextChar = String.fromCharCode(lastChar.codeUnitAt(0) + 1);
    return s.substring(0, s.length - 1) + nextChar;
  }
}

