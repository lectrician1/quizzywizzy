import 'package:flutter/foundation.dart';

/// Needed to create views
import 'package:flutter/material.dart';

/// Cache
import 'package:quizzywizzy/services/cache.dart';

/// Routing constants
import 'package:quizzywizzy/services/routing_constants.dart';

/// Views
import 'package:quizzywizzy/views/app_home.dart';
import 'package:quizzywizzy/views/home.dart';
import 'package:quizzywizzy/views/loading.dart';
import 'package:quizzywizzy/views/single_question.dart';
import 'package:quizzywizzy/views/study_set.dart';
import 'package:quizzywizzy/views/route_not_found.dart';

/// Helper function that adds a [MaterialPage] to [pages]
void addPage(Widget widget, List<Page<dynamic>> pages) {
  pages.add(MaterialPage(child: widget));
}

class AppStack extends ChangeNotifier {

  /// The URL as a list
  /// 
  /// e.g. [courses, AP Calculus BC, Unit 1]
  List<String?>? _hierarchy;

  /// Stores the hierarchy of the previous page visited
  /// to go back to that page after a [pop] of a temporary page.
  List<String?>? _lastHierarchy;

  List<Map<String, dynamic>> views;

  List<String?>? get hierarchy => _hierarchy;

  AppStack({required List<String?> hierarchy})
      : _hierarchy = hierarchy,

        /// This is needed for now since [_getPages] is called when
        /// the app launches before updateStack
        views = [
          {"view": View.home}
        ];

  /// Set a new hierarchy
  ///
  /// Used to set the requested url
  void setStack(List<String?> otherHierarchy) {
    _hierarchy = List.from(otherHierarchy);
    notifyListeners();
  }

  /// Copy an AppStack
  /// 
  /// Used to copy between [_requested] and [_curr]
  void copyStack(AppStack stack) {
    _hierarchy = List.from(stack._hierarchy!);
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
      hierarchy!.clear();

    /// Otherwise, remove last from hierarchy,
    /// which removes last from url,
    /// which removes the top view
    else
      hierarchy!.removeLast();

    notifyListeners();
  }

  /// Add a page to the hierarchy and view stack
  void push(String? pathSegment) {
    _hierarchy!.add(pathSegment);
    notifyListeners();
  }

  /// Push a temporary hierarchy (url) but no view
  void pushTemp(List<String?> newHierarchy) {
    _lastHierarchy = _hierarchy;
    _hierarchy = newHierarchy;
    notifyListeners();
  }
}

/// A class that updates the [Navigator] based on updates to [_requested].
///
/// Use Get.find<AppRouterDelegate>() to get the current instance of this class (make sure to include <>).
class AppRouterDelegate extends RouterDelegate<AppStack>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppStack> {
  final GlobalKey<NavigatorState> navigatorKey;

  /// A stack that calls [_updateStack] whenever there is a change in hierarchy.
  ///
  /// It accomplishes this by adding [_updateStack] as a listener.
  /// This is also used by [currentConfiguration] to send an [AppStack] to [AppRouteInformationParser] to parse into the current url (not always the same as the currently rendered pages).
  AppStack _requested;

  /// A stack that represents the currently rendered pages.
  AppStack _curr;

  /// Represents whether or not [_updateStack] has already been called.
  bool _loading;

  AppStack get currentConfiguration => _requested;

  /// Main constructor that initializes all of the needed AppStacks for 
  /// the routerand more
  /// 
  /// The stuff after the colon always excecutes before the stuff 
  /// after the brackets
  AppRouterDelegate()
      : navigatorKey = GlobalKey<NavigatorState>(),
        _requested = AppStack(hierarchy: []),
        _curr = AppStack(hierarchy: []),
        _loading = false {

    /// Add [_updateStack] as listener function
    /// [_updateStack] is called every time [_requested] is changed
    _requested.addListener(_updateStack);
  }

  /// Build the [Navigator]-based router
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: List.unmodifiable(_getPages()),
      onPopPage: (route, result) => route.didPop(result),
    );
  }

  /// Used by Router
  /// 
  /// This has to be a [AppStack.hierarchy] because [AppRouteInformationParser]
  /// sets starting hierarchy but doesn't initialize [_requested].
  /// It's pretty stupid.
  bool canPop() {
    return _requested.hierarchy!.length > 0;
  }

  /// [_loading]-dependent [AppStack] method reimplementations

  /// Go back to intended view or url dependening on router state
  void pop() {
    if (_loading) return;
    _requested.pop();
  }

  /// Add a page to the hierarchy and view stack
  void push(String? pathSegment) {
    if (_loading) return;
    _requested.push(pathSegment);
  }

  /// Push a temporary hierarchy (url) but no view
  void pushTemp(List<String?> newHierarchy) {
    if (_loading) return;
    _requested.pushTemp(newHierarchy);
  }

  /// Set a new hierarchy
  void setStack(List<String> hierarchy) {
    if (_loading) return;
    _requested.setStack(hierarchy);
  }

  /// Tests [_requested.hierarchy] and [_requested.lastHierarchy]'s state to see 
  /// if [_requested.hierarchy] (the url) or views need to change.
  ///
  /// Runs about whenever [notifyListeners] is called
  Future<void> _updateStack() async {
    /// If loading
    if (_loading) return;
    _loading = true;

    /// Notify listeners to show loading page
    notifyListeners();

    /// If not a [tempPush], get and set new [views] for [_requested].
    if (!listEquals(_requested._lastHierarchy, _curr.hierarchy)) {
      _requested.views = await (getViews(_requested.hierarchy!));
    }

    /// Copy [_requested.hierarchy] and [_requested.views] to [_curr] for 
    /// page rendering and future [tempPush] references.
    _curr.copyStack(_requested);

    /// Finish
    _loading = false;

    /// Notify listeners to show actual page
    notifyListeners();
  }

  /// Generates pages for the [Navigator] based on [_curr.views]
  List<Page<dynamic>> _getPages() {
    // Page stack in order
    List<Page<dynamic>> pages = [];

    print(_curr.views);

    /// Add each of the views to pages
    for (int i = 0; i < _curr.views.length; i++) {
      switch (_curr.views[i]["view"]) {
        case View.home:
          addPage(HomeView(), pages);
          break;
        case View.courses:
        case View.units:
        case View.topics:
        case View.subtopics:
          addPage(AppHomeView(collection: _curr.views[i]["reference"]), pages);
          break;
        case View.questions:
          addPage(StudySetView(questionsPage: _curr.views[i]["reference"]), pages);
          break;
        case View.notFound:
          addPage(RouteNotFoundView(name: Uri.base.toString()), pages);
          break;
        default:
          break;
      }
    }

    // Show loading view if page is loading.
    if (_loading) {
      addPage(LoadingView(), pages);
    }
    
    return pages;
  }

  @override
  Future<void> setNewRoutePath(AppStack stack) async {
    if (_loading) return;
    if (stack.hierarchy!.length > 0) _requested.setStack(stack.hierarchy!);
  }
}

/// Returns an AppStack using the current URL
class AppRouteInformationParser extends RouteInformationParser<AppStack> {
  @override
  Future<AppStack> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);
    return AppStack(hierarchy: uri.pathSegments);
  }

  @override
  RouteInformation restoreRouteInformation(AppStack page) {
    RouteInformation route;
    route = RouteInformation(location: getRoute(page.hierarchy!));
    return route;
  }
}
