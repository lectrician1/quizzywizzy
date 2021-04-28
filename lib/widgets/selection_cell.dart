import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SelectionCell extends StatefulWidget {
  final double width;
  final double height;
  final int type;
  final String text;
  final Function onTap;
  final IconData icon;
  SelectionCell(
      {@required this.text,
      @required this.icon,
      this.width = 250,
      this.height = 250,
      @required this.type,
      @required this.onTap});
  @override
  _SelectionCellState createState() => _SelectionCellState(
      text: text,
      icon: icon,
      width: width,
      height: height,
      type: type,
      onTap: onTap);
}

class _SelectionCellState extends State<SelectionCell> {
  final double width;
  final double height;
  final int type;
  final String text;
  final Function onTap;
  final IconData icon;
  bool hovered = false;
  _SelectionCellState(
      {@required this.text,
      @required this.icon,
      @required this.width,
      @required this.height,
      @required this.type,
      @required this.onTap});

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.0)),
        child: GestureDetector(
            onTap: onTap,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (e) => setState(() => hovered = true),
              onExit: (e) => setState(() => hovered = false),
              child: CustomPaint(
                size: Size(width, height),
                painter: TilePainter(
                    type: type,
                    fillColor: Colors.grey[50],
                    strokeColor: Color(0xff1b5e20),
                    strokeWidth: 0.25,
                    elevation: 5,
                    hovered: hovered),
                child: Column(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Center(
                          child: Icon(icon),
                        )),
                    Expanded(
                      flex: 1,
                      child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          child: Text(text,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, height: 1.35))),
                    ),
                  ],
                ),
              ),
            )));
  }
}

class TilePainter extends CustomPainter {
  final Color fillColor;
  final Color strokeColor;
  final double elevation;
  final double strokeWidth;
  final int type;
  final bool hovered;
  TilePainter(
      {@required this.type,
      @required this.fillColor,
      @required this.strokeColor,
      @required this.strokeWidth,
      @required this.elevation,
      @required this.hovered});
  @override
  void paint(Canvas canvas, Size size) {
    double borderRadius = 15;
    Paint fillPaint = new Paint()..color = fillColor;
    Paint strokePaint = new Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    Path path = Path();
    switch (type) {
      case 0:
        double foldDistance = 35;
        path
          ..moveTo(0, borderRadius)
          ..lineTo(0, size.height - borderRadius)
          ..arcTo(
              Rect.fromCircle(
                  center: Offset(borderRadius, size.height - borderRadius),
                  radius: borderRadius),
              pi,
              -0.5 * pi,
              false)
          ..lineTo(size.width - borderRadius, size.height)
          ..arcTo(
              Rect.fromCircle(
                  center: Offset(
                      size.width - borderRadius, size.height - borderRadius),
                  radius: borderRadius),
              0.5 * pi,
              -0.5 * pi,
              false)
          ..lineTo(size.width, foldDistance)
          ..lineTo(size.width - foldDistance, 0)
          ..lineTo(borderRadius, 0)
          ..arcTo(
              Rect.fromCircle(
                  center: Offset(borderRadius, borderRadius),
                  radius: borderRadius),
              1.5 * pi,
              -0.5 * pi,
              false)
          ..close();
        break;
      case 1:
        double folderRadius = 5;
        path
          ..moveTo(0, borderRadius)
          ..lineTo(0, size.height - borderRadius)
          ..arcTo(
              Rect.fromCircle(
                  center: Offset(borderRadius, size.height - borderRadius),
                  radius: borderRadius),
              pi,
              -0.5 * pi,
              false)
          ..lineTo(size.width - borderRadius, size.height)
          ..arcTo(
              Rect.fromCircle(
                  center: Offset(
                      size.width - borderRadius, size.height - borderRadius),
                  radius: borderRadius),
              0.5 * pi,
              -0.5 * pi,
              false)
          ..lineTo(size.width, borderRadius + folderRadius * 2)
          ..arcTo(
              Rect.fromCircle(
                  center: Offset(size.width - borderRadius,
                      borderRadius + folderRadius * 2),
                  radius: borderRadius),
              2 * pi,
              -0.5 * pi,
              false)
          ..lineTo(size.width / 2 + folderRadius, folderRadius * 2)
          ..arcTo(
              Rect.fromCircle(
                  center: Offset(size.width / 2 + folderRadius, folderRadius),
                  radius: folderRadius),
              0.5 * pi,
              0.5 * pi,
              false)
          ..arcTo(
              Rect.fromCircle(
                  center: Offset(size.width / 2 - folderRadius, folderRadius),
                  radius: folderRadius),
              2 * pi,
              -0.5 * pi,
              false)
          ..lineTo(borderRadius, 0)
          ..arcTo(
              Rect.fromCircle(
                  center: Offset(borderRadius, borderRadius),
                  radius: borderRadius),
              1.5 * pi,
              -0.5 * pi,
              false)
          ..close();
        break;
      case 2:
        path.addRRect(RRect.fromRectAndRadius(
            Rect.fromLTRB(0, 0, size.width, size.height),
            Radius.circular(borderRadius)));
        break;
    }

    if (hovered) canvas.drawShadow(path, strokeColor, elevation, false);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant TilePainter oldDelegate) {
    return hovered != oldDelegate.hovered;
  }
}
