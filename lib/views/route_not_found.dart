import 'package:flutter/material.dart';
import 'package:quizzywizzy/widgets/navigation_bar.dart';

class RouteNotFoundView extends StatelessWidget {
  final String _name;
  const RouteNotFoundView({@required String name}) : _name = name;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NavigationBar(
        title: "$_name cannot be found",
        body: Container(),
      )
    );
  }
}
