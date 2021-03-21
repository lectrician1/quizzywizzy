import 'package:flutter/material.dart';
import 'package:quizzywizzy/widgets/body_template.dart';

class SingleQuestionView extends StatelessWidget {
  final String id;
  SingleQuestionView() : id = "";
  SingleQuestionView.id({@required this.id});
  @override
  Widget build(BuildContext context) {
    return BodyTemplate(child: Text("Single Question"));
  }
}
