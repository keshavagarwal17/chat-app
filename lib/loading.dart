import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color:Color(0xff181a21),
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: CircularProgressIndicator(
          valueColor:AlwaysStoppedAnimation(Colors.blue),
          strokeWidth: 7,
        ),
    );
  }
}