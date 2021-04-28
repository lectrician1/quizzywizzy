import 'package:flutter/material.dart';
import 'package:quizzywizzy/constants.dart';
import 'package:quizzywizzy/widgets/navigation_bar.dart';

class BodyTemplate extends StatelessWidget {
  final String title;
  final double constraintWidth;
  final Widget child;
  BodyTemplate(
      {this.title = Constants.title,
      this.constraintWidth = Constants.constraintWidth,
      @required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NavigationBar(
      title: title,
      child: SafeArea(
        child: Scrollbar(
          child: Align(
            alignment: Alignment.topCenter,
            child: LayoutBuilder(
              builder: (context, constraints) => Container(
                width: (constraints.maxWidth > constraintWidth) ? constraintWidth : constraints.maxWidth,
                child: child,
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
