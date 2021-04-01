import 'package:flutter/material.dart';
import 'package:quizzywizzy/constants.dart';
import 'package:quizzywizzy/widgets/navigation_bar.dart';

class BodyTemplate extends StatelessWidget {
  final String title;
  final double constraintWidth;
  final Widget child;
  BodyTemplate(
      {this.title = Constants.title,
      // constraintWidth
      this.constraintWidth = 1150,
      @required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NavigationBar(
      title: title,
      constraintWidth: constraintWidth,
      child: SafeArea(
        child: Scrollbar(
          child: Align(
            alignment: Alignment.topCenter,
            child: Stack(
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: constraintWidth),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
