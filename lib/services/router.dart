import 'package:flutter/foundation.dart';

/// Needed to create views
import 'package:flutter/material.dart';
import 'package:quizzywizzy/services/AppStack.dart';

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
    return _requested.hierarchy.length > 0;
  }

  /// [_loading]-dependent [AppStack] method reimplementations

  /// Go back to intended view or url dependening on router state
  void pop() {
    if (_loading) return;
    _requested.pop();
  }

  /// Add a page to the hierarchy and view stack
  void push(String pathSegment) {
    if (_loading) return;
    _requested.push(pathSegment);
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
    
    _requested.views = await getViews(_requested.hierarchy);

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
          addPage(StudySetView(collection: _curr.views[i]["reference"]), pages);
          break;
        case View.question:
          addPage(SingleQuestionView(), pages);
          break;
        case View.sproutset:
          addPage(StudySetView(collection: _curr.views[i]["reference"]), pages);
          break;
        case View.user:
          addPage(LoadingView(), pages);
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
    if (stack.hierarchy.length > 0) _requested.setStack(stack.hierarchy);
  }
}

class AppRouteInformationProvider extends RouteInformationProvider with ChangeNotifier{

}

/// Returns an AppStack using the current URL
class AppRouteInformationParser extends RouteInformationParser<AppStack> {
  @override
  
  
  @override
  Future<AppStack> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location);
    return AppStack(hierarchy: uri.pathSegments);
  }

  @override
  RouteInformation restoreRouteInformation(AppStack page) {
    RouteInformation route;
    route = RouteInformation(location: getRoute(page.hierarchy));
    return route;
  }
}
