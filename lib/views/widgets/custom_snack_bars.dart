import 'package:flutter/material.dart';

class InfoSnackBar extends SnackBar {
  final String text;
  InfoSnackBar({@required this.text})
      : super(
            content: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 10),
                Flexible(
                  child: Text(
                    text,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[900],
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
                label: "Got it", textColor: Colors.white, onPressed: () {}),
            duration: Duration(seconds: 10));
}
