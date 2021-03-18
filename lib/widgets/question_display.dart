import 'package:flutter/material.dart';
import 'package:quizzywizzy/models/question_model.dart';

class QuestionDisplay extends StatelessWidget {
  final QuestionModel questionData;
  QuestionDisplay({@required this.questionData});
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Text(questionData.questionText),
        Text(questionData.choices.toString()),
      ]);
  }
}