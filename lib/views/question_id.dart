import 'package:flutter/material.dart';
import 'package:quizzywizzy/models/question_model.dart';
import 'package:quizzywizzy/widgets/question_display.dart';
import 'package:quizzywizzy/widgets/body_template.dart';

class QuestionIDView extends StatelessWidget {
  final QuestionModel questionData;
  QuestionIDView({@required this.questionData});
  @override
  Widget build(BuildContext context) {
    return BodyTemplate(
        child: QuestionDisplay(questionData: questionData));
  }
}