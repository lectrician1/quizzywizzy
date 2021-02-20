import 'package:flutter/material.dart';
import 'package:quizzywizzy/views/widgets/navigation_bar.dart';

class RouteNotFoundView extends StatelessWidget {
  final String _name;
  const RouteNotFoundView({String name}) : _name = name;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NavigationBar(
        backButtonRoute: "",
        backButtonShouldPop: true,
        title: "$_name cannot be found",
        body: Container(),
      )
    );
  }
}
