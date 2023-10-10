import 'package:flutter/material.dart';
import 'package:collab/personal_spaces/model/todo.dart';

class TodoView extends StatefulWidget {
  Todo todo;
  TodoView({Key? key, required this.todo}) : super(key: key);

  @override

  _TodoViewState createState() => _TodoViewState(todo: todo);
}

class _TodoViewState extends State<TodoView> {
  Todo todo;
  _TodoViewState({required this.todo});
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (todo != null) {
      titleController.text = todo.title!;
      descriptionController.text = todo.description!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar : AppBar(
        centerTitle: true,
        title : const Text("Personal Checklist", style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
      ),
      body: Container(
          decoration: BoxDecoration(
          image: DecorationImage(
          image: AssetImage('assets/images/checklist-ui.webp'),
          fit: BoxFit.cover)),
        child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [
          Colors.black.withOpacity(0.8),
          Colors.black.withOpacity(0.7)
          ])),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  padding: EdgeInsets.all(10),
                  child: colorOverride(
                    TextField(
                    onChanged: (data) {
                      todo.title = data;
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: "What do you want to remember? ",
                      fillColor: Colors.white.withOpacity(0.3),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      //fillColor: Colors.green
                    ),
                    controller: titleController,
                  ))),
              SizedBox(
                height: 25,
              ),
              Container(
                  padding: EdgeInsets.all(10),
                  child: colorOverride(
                    TextField(
                    maxLines: 5,
                    onChanged: (data) {
                      todo.description = data;
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: "Any description for it?",
                      fillColor: Colors.white.withOpacity(0.3),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      //fillColor: Colors.green
                    ),
                    controller: descriptionController,
                  ))),
            ],
          ),)
        ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.7)
            ])),
        height: 55.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Alert"),
                          content: Text(
                              "Mark this todo as ${todo.status! ? 'not done' : 'done'}  "),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("No"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  todo.status = !todo.status!;
                                });
                                Navigator.of(context).pop();
                                Navigator.pop(context, todo);
                              },
                              child: Text("Yes"),
                            )
                          ],
                        ));
                  },
                  child: Text(
                    "${todo.status! ? 'Mark as Not Done' : 'Mark as Done'} ",
                    style: TextStyle(color: Colors.white),
                  )),
              VerticalDivider(
                color: Colors.white,
              ),
              IconButton(
                icon: Icon(Icons.save, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context, todo);
                },
              )
            ],
          ),
      ),
    );
  }

  Widget colorOverride(Widget child) {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.white,
        hintColor: Colors.white, colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
      ),
      child: child,
    );
  }
}
