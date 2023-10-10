import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: double.infinity,
      // Here i can use size.width but use double.infinity because both work as a same
      child: Stack(
        children: <Widget>[
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              "assets/images/bottomcurve.png",
              width: size.width * 1.0,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
