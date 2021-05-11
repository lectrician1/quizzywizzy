import 'package:flutter/material.dart';
import 'package:quizzywizzy/services/routing_constants.dart';

class AppStack extends ChangeNotifier {
  /// The URL as a list
  ///
  /// e.g. [courses, AP Calculus BC, Unit 1]
  List<String> _hierarchy;

  /// Stores the hierarchy of the previous page visited
  /// to go back to that page after a [pop] of a temporary page.
  List<String> _lastHierarchy;

  List<Map<String, dynamic>> views;

  List<String> get hierarchy => _hierarchy;
  List<String> get lastHierarchy => _lastHierarchy;

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
    /// If tempPush
    if (_lastHierarchy != null) {
      /// Revert to last hierarchy
      _hierarchy = _lastHierarchy;

      /// Set to null to prevent view from not being actually popped after
      /// a [_lastHierarchy] was assigned since this condtional block depends
      /// on [_lastHierarchy != null]
      ///
      /// For example, if a tempPush to a question view occured and
      /// the user popped with [_lastHierarchy] not being set to null afterwards,
      /// the next time they pop, since [_lastHierarchy != null],
      /// the intended [hierarchy.removeLast()] would not occur and
      /// this condition would instead.
      _lastHierarchy = null;
    }

    /// If question view, clear [hierarcy] to go to home
    ///
    /// We cannot just [removeLast] because the route for this view is:
    /// "/questions/questionid"
    ///
    /// And "/questions" has no page and we want to go to home ("/")
    else if (views.last["view"] == View.question)
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

  /// Push a temporary hierarchy (url) but no view
  void pushTemp(List<String> newHierarchy) {
    _lastHierarchy = _hierarchy;
    _hierarchy = newHierarchy;
    notifyListeners();
  }
}