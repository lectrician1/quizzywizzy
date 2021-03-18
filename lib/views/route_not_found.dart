import 'package:flutter/material.dart';
import 'package:quizzywizzy/widgets/body_template.dart';

class RouteNotFoundView extends StatelessWidget {
  final String _name;
  const RouteNotFoundView({@required String name}) : _name = name;
  @override
  Widget build(BuildContext context) {
    return BodyTemplate(
        title: "$_name cannot be found",
        child: Container());
  }
}
