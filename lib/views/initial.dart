import 'package:flutter/material.dart';
import 'package:quizzywizzy/constants.dart' as Constants;

class InitialView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  InitialView redirect(BuildContext context) {
    Future.microtask(() {
      Navigator.of(context).pushReplacementNamed(Constants.getHomeRoute());
    });
    return this;
  }
}
