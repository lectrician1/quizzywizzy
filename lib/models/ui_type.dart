import 'package:flutter/material.dart';

class UIType extends ChangeNotifier {
  String? _type;
  String? get type => _type;

  set type(String? newType) {
    _type = newType;
    notifyListeners();
  }
  
  UIType() : _type = "Student";
}