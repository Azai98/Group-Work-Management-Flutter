
import 'package:flutter/material.dart';

class DisplayImage extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;

  // Constructor
  const DisplayImage({
    Key? key,
    required this.imagePath,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Color.fromRGBO(64, 105, 225, 1);

    return Center(
        child: Stack(children: [
      buildImage(color),
      Positioned(
        child: buildEditIcon(color),
        right: 4,
        top: 10,
      )
    ]));
  }

  // Builds Profile Image
  Widget buildImage(Color color) {
    return CircleAvatar(
      radius: 75,
      backgroundColor: Colors.white70,
      child: Center(
        child: imagePath == ''
            ? CircleAvatar(
          radius: 75.0,
          backgroundColor: Colors.white.withOpacity(0.3),
          child: Icon(Icons.photo_camera),
        )
            : CircleAvatar(
          radius: 75.0,
          backgroundColor: Colors.white.withOpacity(0.3),
          backgroundImage: NetworkImage(imagePath),
        ),
      ),
    );
  }

  // Builds Edit Icon on Profile Picture
  Widget buildEditIcon(Color color) => buildCircle(
      all: 8,
      child: Icon(
        Icons.edit,
        color: color,
        size: 20,
      ));

  // Builds/Makes Circle for Edit Icon on Profile Picture
  Widget buildCircle({
    required Widget child,
    required double all,
  }) =>
      ClipOval(
          child: Container(
          padding: EdgeInsets.all(all),
          color: Colors.white,
          child: child,
      ));
}


