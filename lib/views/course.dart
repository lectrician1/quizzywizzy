import 'package:flutter/material.dart';
import 'package:quizzywizzy/views/widgets/navigation_bar.dart';

class CourseView extends StatelessWidget {
  final String _course;
  CourseView({String course}) : _course = course;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NavigationBar(
        title: "QuizzyWizzy$_course",
        body: Container(),
      ),
    );
  }
}
