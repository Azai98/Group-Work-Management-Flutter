import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collab/personal_spaces/model/todo.dart';
import 'package:collab/personal_spaces/todoview.dart';

class userChecklist extends StatefulWidget {
  const userChecklist({Key? key}) : super(key: key);

  @override
  _userChecklist createState() => _userChecklist();
}

class _userChecklist extends State<userChecklist> {
  late SharedPreferences prefs;
  List todos = [];
  setupTodo() async {
    prefs = await SharedPreferences.getInstance();
    String? stringTodo = prefs.getString('todo');
    List todoList = jsonDecode(stringTodo!);
    for (var todo in todoList) {
      setState(() {
        todos.add(Todo().fromJson(todo));
      });
    }
  }

  void saveTodo() {
    List items = todos.map((e) => e.toJson()).toList();
    prefs.setString('todo', jsonEncode(items));
  }

  @override
  void initState() {
    super.initState();
    setupTodo();
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
        child:ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: todos.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
                elevation: 8.0,
                margin:
                EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(64, 75, 96, .9),
                  ),
                  child: InkWell(
                    onTap: () async {
                      Todo t = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TodoView(todo: todos[index])));
                      if (t != null) {
                        setState(() {
                          todos[index] = t;
                        });
                        saveTodo();
                      }
                    },
                    child: makeListTile(todos[index], index),
                  ),
                ));
                }),
            )
        ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.white.withOpacity(0.3),
        onPressed: () {
          addTodo();
        },
      ),
    );
  }

  addTodo() async {
    int id = Random().nextInt(30);
    Todo t = Todo(id: id, title: '', description: '', status: false);
    Todo returnTodo = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => TodoView(todo: t)));
    if (returnTodo != null) {
      setState(() {
        todos.add(returnTodo);
      });
      saveTodo();
    }
  }

  makeListTile(Todo todo, index) {
    return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 13.0),
        leading: Container(
          padding: EdgeInsets.only(right: 12.0),
          decoration: BoxDecoration(
              border: Border(
                  right: BorderSide(width: 1.0, color: Colors.white24))),
          child: CircleAvatar(
            backgroundColor: Colors.black26,
            child: Text("${index + 1}"),
          ),
        ),
        title: Row(
          children: [
            Text(
              todo.title!,
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 10,
            ),
            todo.status!
                ? Icon(
              Icons.verified,
              color: Colors.greenAccent,
            )
                : Container()
          ],
        ),
        // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

        subtitle: Wrap(
          children: <Widget>[
            Text(todo.description!,
                overflow: TextOverflow.clip,
                maxLines: 1,
                style: TextStyle(color: Colors.white))
          ],
        ),
        trailing: InkWell(
            onTap: () {
              delete(todo);
            },
            child: Icon(Icons.delete, color: Colors.white, size: 30.0)));
  }

  delete(Todo todo) {
    return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Delete confirmation"),
          content: Text("Are you sure to delete?"),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: Text("No")),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    todos.remove(todo);
                  });
                  Navigator.pop(ctx);
                  saveTodo();
                },
                child: Text("Yes"))
          ],
        ));
  }
}