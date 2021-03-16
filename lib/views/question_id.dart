import 'package:flutter/material.dart';
import 'package:quizzywizzy/models/question_model.dart';
import 'package:quizzywizzy/widgets/navigation_bar.dart';
import 'package:quizzywizzy/constants.dart';
import 'package:quizzywizzy/widgets/question_display.dart';
import 'package:quizzywizzy/widgets/resizer.dart';

class QuestionIDView extends StatelessWidget {
  final QuestionModel questionData;
  QuestionIDView({@required this.questionData});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NavigationBar(
            title: Constants.title,
            body: WidthResizer(
                widthFactor: 0.75,
                constraintWidth: 800,
                builder: (context, contraints) => QuestionDisplay(questionData: questionData))));
  }
}
