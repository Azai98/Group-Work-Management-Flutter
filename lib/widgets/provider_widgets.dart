import 'package:collab/auth_service.dart';
import 'package:flutter/material.dart';

class Provider extends InheritedWidget {
  final AuthService auth;
  // ignore: prefer_typing_uninitialized_variables
  final db;

  const Provider({Key? key, required Widget child, required this.auth, this.db}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static Provider? of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<Provider>());
}