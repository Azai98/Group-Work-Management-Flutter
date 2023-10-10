// class Task {
//   final String taskID;
//   final bool complete;
//   final DateTime completeTime;
//   Task(this.taskID,this.complete,this.completeTime);
//
//   Task.fromMap(Map<String, dynamic> map)
//       : assert(map['taskID'] != null),
//         assert(map['complete'] != null),
//         assert(map['completeTime'] != null),
//         taskID = map['taskID'],
//         complete = map['complete'],
//         completeTime = DateTime.parse(map['completeTime']);
//
//
//   // StreamBuilder<QuerySnapshot>(
//   // stream: FirebaseFirestore.instance.collection('projects').doc(widget.projectID).collection('tasks').snapshots(),
//   // builder: (context, snapshot) {
//   // if (!snapshot.hasData) {
//   // return LinearProgressIndicator();
//   // } else {
//   // List<Task> task = snapshot.data!.docs
//   //     .map((documentSnapshot ) => Task.fromMap(documentSnapshot.data() as Map<String,dynamic>))
//   //     .toList();
//   // return _buildChart(context, task);
//   // }
//   // },
//   // );
// }

class Task {
  final DateTime completeTime;
  final int taskCompletedPerday;

  Task(this.completeTime, this.taskCompletedPerday);
}
