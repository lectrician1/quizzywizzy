import 'package:flutter/material.dart';

enum QuestionType {
  multipleChoice,
  freeResponse,
}

class QuestionModel {
  final QuestionType type;
  final String questionText;
  final List<String> choices;
  final int answer;
  final List<String> explanations;
  QuestionModel(
      {required this.type,
      required this.questionText,
      required this.choices,
      required this.answer,
      required this.explanations})
      : assert(choices.length == explanations.length),
        assert(answer < choices.length);
  
  QuestionModel.multipleChoice(
      {required this.questionText,
      required this.choices,
      required this.answer,
      required this.explanations})
      : assert(choices.length == explanations.length),
        assert(answer < choices.length),
        this.type = QuestionType.multipleChoice;
  
  QuestionModel.freeResponse({
      required this.questionText,
      required String answer,
      required String explanation})
      : this.answer = 0,
      this.type = QuestionType.freeResponse,
      this.choices = [answer],
      this.explanations = [explanation];
  
  String getAnswer() => choices[answer];
}
