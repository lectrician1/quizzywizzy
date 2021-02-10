import 'package:flutter/material.dart';
import 'views/home.dart';
import 'views/start.dart';

void main() => runApp(MaterialApp(
  initialRoute: '/home',
  routes: {
    '/': (context) => Start(),
    '/home': (context) => Home(),
  }
));
