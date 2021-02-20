import 'package:flutter/material.dart';
import 'package:quizzywizzy/views/widgets/navigation_bar.dart';
import 'package:quizzywizzy/constants.dart' as Constants;

class CourseView extends StatelessWidget {
  final String _course;
  CourseView({String course}) : _course = course;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NavigationBar(
        backButtonRoute: Constants.getHomeRoute(),
        title: Constants.title + "$_course",
        body: Container(),
      ),
    );
  }
}
