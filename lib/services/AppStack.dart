import 'package:flutter/material.dart';
import 'package:quizzywizzy/services/routing_constants.dart';

class AppStack extends ChangeNotifier {
  /// The URL as a list
  ///
  /// e.g. [courses, AP Calculus BC, Unit 1]
  List<String> _hierarchy;

  List<Map<String, dynamic>> views;

  List<String> get hierarchy => _hierarchy;

  AppStack({@required List<String> hierarchy})
      : _hierarchy = hierarchy,

        /// This is needed for now since [_getPages] is called when
        /// the app launches before updateStack
        views = [
          {"view": View.home}
        ];

  /// Set a new hierarchy
  ///
  /// Used to set the requested url
  void setStack(List<String> otherHierarchy) {
    _hierarchy = List.from(otherHierarchy);
    notifyListeners();
  }

  /// Copy an AppStack
  ///
  /// Used to copy between [_requested] and [_curr]
  void copyStack(AppStack stack) {
    _hierarchy = List.from(stack._hierarchy);
    views = List.from(stack.views);
  }

  /// Go back to intended view or url dependening on router state
  void pop() {

    /// If question view, clear [hierarcy] to go to home
    ///
    /// We cannot just [removeLast] because the route for this view is:
    /// "/questions/questionid"
    ///
    /// And "/questions" has no page and we want to go to home ("/")
    if (views.last["view"] == View.question)
      hierarchy.clear();

    /// Otherwise, remove last from hierarchy,
    /// which removes last from url,
    /// which removes the top view
    else
      hierarchy.removeLast();

    notifyListeners();
  }

  /// Add a page to the hierarchy and view stack
  void push(String pathSegment) {
    _hierarchy.add(pathSegment);
    notifyListeners();
  }
}