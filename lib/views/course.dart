import 'package:flutter/material.dart';

class CourseView extends StatelessWidget {
  final String _course;
  CourseView({String course}) :
  _course = course;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        title: Text("QuizzyWizzy$_course"),
        floating: true,
      ),
    ];
      },
      body: Container(),
    ));
  }
}
