import 'dart:math';

import 'package:flutter/material.dart';

class SelectionCell extends StatelessWidget {
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
      this.type = 0,
      @required this.onTap});

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    return Ink(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0)
      ),
      child: InkWell(
        splashColor: Colors.blue,
        onTap: onTap,
        child: CustomPaint(
          size: Size(width, height),
          painter: getPainter(type, Colors.grey, 5),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Center(
                  child: Icon(icon),
                )
              ),
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, height: 1.35))),
              ),
            ],
          ),
        )
      )
    );
  }
  CustomPainter getPainter(int type, Color color, double strokeWidth) {
    CustomPainter painter = BoxPainter(color: color, strokeWidth: strokeWidth);
    switch(type) {
      case 0:
        painter = BoxPainter(color: color, strokeWidth: strokeWidth);
        break;
      case 1:
        painter = FolderPainter(color: color, strokeWidth: strokeWidth);
        break;
    }
    return painter;
  }
}

class FolderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  FolderPainter({@required this.color, @required this.strokeWidth});
  @override
  void paint(Canvas canvas, Size size) {
    double borderRadius = 15;
    double folderRadius = 5;
    double elevation = 4;
  Paint paint = new Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    Path path = Path()
    ..moveTo(0, borderRadius)
    ..lineTo(0, size.height-borderRadius)
    ..arcTo(Rect.fromCircle(center: Offset(borderRadius, size.height-borderRadius), radius: borderRadius), 0.5*pi, 0.5*pi, true)
    ..moveTo(borderRadius, size.height)
    ..lineTo(size.width-borderRadius, size.height)
    ..arcTo(Rect.fromCircle(center: Offset(size.width-borderRadius, size.height-borderRadius), radius: borderRadius), 0, 0.5*pi, true)
    ..moveTo(size.width, size.height-borderRadius)
    ..lineTo(size.width, borderRadius+folderRadius*2)
    ..arcTo(Rect.fromCircle(center: Offset(size.width-borderRadius, borderRadius+folderRadius*2), radius: borderRadius), 1.5*pi, 0.5*pi, true)
    ..moveTo(size.width-borderRadius, folderRadius*2)
    ..lineTo(size.width/2+folderRadius, folderRadius*2)
    ..arcTo(Rect.fromCircle(center: Offset(size.width/2+folderRadius, folderRadius), radius: folderRadius), 0.5*pi, 0.5*pi, true)
    ..arcTo(Rect.fromCircle(center: Offset(size.width/2-folderRadius, folderRadius), radius: folderRadius), 1.5*pi, 0.5*pi, true)
    ..moveTo(size.width/2-folderRadius, 0)
    ..lineTo(borderRadius, 0)
    ..arcTo(Rect.fromCircle(center: Offset(borderRadius, borderRadius), radius: borderRadius), pi, 0.5*pi, true);
    canvas.drawPath(path, paint);
    Path path2 = Path()
    ..arcTo(Rect.fromCircle(center: Offset(borderRadius, size.height-borderRadius-elevation), radius: borderRadius), 0.5*pi, 0.5*pi, true)
    ..moveTo(borderRadius, size.height-elevation)
    ..lineTo(size.width-borderRadius, size.height-elevation)
    ..arcTo(Rect.fromCircle(center: Offset(size.width-borderRadius, size.height-borderRadius-elevation), radius: borderRadius), 0, 0.5*pi, true);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
  
}

class BoxPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  BoxPainter({@required this.color, @required this.strokeWidth});
  @override
  void paint(Canvas canvas, Size size) {
    double borderRadius = 15;
    double elevation = 4;
  Paint paint = new Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(0, 0, size.width, size.height), Radius.circular(borderRadius)), paint);
    Path path2 = Path()
    ..arcTo(Rect.fromCircle(center: Offset(borderRadius, size.height-borderRadius-elevation), radius: borderRadius), 0.5*pi, 0.5*pi, true)
    ..moveTo(borderRadius, size.height-elevation)
    ..lineTo(size.width-borderRadius, size.height-elevation)
    ..arcTo(Rect.fromCircle(center: Offset(size.width-borderRadius, size.height-borderRadius-elevation), radius: borderRadius), 0, 0.5*pi, true);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
  
}