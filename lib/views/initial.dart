import 'package:flutter/material.dart';

class InitialView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      Navigator.pushReplacementNamed(context, "/courses");
    });
    return Container();
  }
}
