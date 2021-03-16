import 'package:flutter/material.dart';

class WidthResizer extends StatelessWidget {
  final Widget Function(BuildContext, BoxConstraints) builder;
  final double constraintWidth;
  final double widthFactor;
  WidthResizer({@required this.widthFactor, @required this.constraintWidth, @required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > constraintWidth / widthFactor) {
          return FractionallySizedBox(
            widthFactor: widthFactor,
            child: builder(context, constraints),
          );
        } else {
          return Container(
            constraints: BoxConstraints(maxWidth: constraintWidth),
            child: builder(context, constraints),
          );
        }
      }
    );
  }
}