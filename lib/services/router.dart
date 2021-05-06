/// Needed to create views
import 'package:flutter/material.dart';

/// Cache
import 'package:quizzywizzy/services/cache.dart';

/// Routing constants
import 'package:quizzywizzy/services/routing_constants.dart';

/// Views
import 'package:quizzywizzy/views/add_question.dart';
import 'package:quizzywizzy/views/app_home.dart';
import 'package:quizzywizzy/views/home.dart';
import 'package:quizzywizzy/views/loading.dart';
import 'package:quizzywizzy/views/single_question.dart';
import 'package:quizzywizzy/views/study_set.dart';
import 'package:quizzywizzy/views/route_not_found.dart';

/// A class that stores a list/stack of path segments (called [hierarchy]).
///
/// e.g. [courses, AP Calculus BC, Unit 1]
///
/// It notifys any listeners whenever there is a change in the [hierarchy].
///
/// It is used for requested and curren
class AppStack extends ChangeNotifier {
  List<String> _hierarchy;
  List<String> _lastHierarchy;
  dynamic views;
  List<String> get hierarchy => _hierarchy;

  PseudoPage _pseudoPage = PseudoPage.none;
  PseudoPage get pseudoPage => _pseudoPage;

  AppStack({@required List<String> hierarchy}) : _hierarchy = hierarchy;

  /// Set a new hierarchy
  ///
  /// Used to set the requested url
  void setStack(List<String> otherHierarchy) {
    _hierarchy = List.from(otherHierarchy);
    _pseudoPage = PseudoPage.none;
    notifyListeners();
  }

  /// Set a new hierarchy using a existing AppStack
  void copyCurrStack(AppStack curr) {
    _hierarchy = List.from(curr._hierarchy);
    _pseudoPage = curr._pseudoPage;
  }

  /// Set a new hierarchy using a existing AppStack
  void copyRequestedStack(AppStack requested) {
    _hierarchy = List.from(requested._hierarchy);
    _pseudoPage = requested._pseudoPage;
  }

  /// Remove a page from the hierarchy
  void pop() {
    if (_pseudoPage == PseudoPage.none)
      _hierarchy.removeLast();
    else if (_lastHierarchy != null) {
      _hierarchy = _lastHierarchy;
      _lastHierarchy = null;
    } else
      _pseudoPage = PseudoPage.none;
    notifyListeners();
  }

  /// Add a page to the hierarchy and view stack
  void push(String pathSegment) {
    _hierarchy.add(pathSegment);
    _pseudoPage = PseudoPage.none;
    notifyListeners();
  }

  void pushTemp(List<String> newHierarchy) {
    _lastHierarchy = _hierarchy;
    _hierarchy = newHierarchy;
  }

  void pushPseudo(PseudoPage page) {
    _pseudoPage = page;
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

  /// Represents any additional page.
  ///
  /// See [AdditionalPage] enum for more details.
  bool _notFound;

  /// Represents whether or not [_updateStack] has already been called.
  bool _loading;

  AppStack get currentConfiguration => _requested;

  /// Main constructor that initializes all of the needed AppStacks for the router
  AppRouterDelegate()
      : navigatorKey = GlobalKey<NavigatorState>(),
        _requested = AppStack(hierarchy: []),

        /// Courses needs to be in the current heirarchy or else getPages will never know what the "first page" is.
        /// This is temporary until an actual homepage is created and getPages can account for no first hierarchy
        _curr = AppStack(hierarchy: []),
        _notFound = false,
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

  bool canPop() {
    return _notFound == true || _requested.hierarchy.length > 1;
  }

  /// pops [_requested] stack. All calls will be ignored if [_loading] == true.
  void pop() {
    if (_loading) return;
    if (_notFound == true) {
      _notFound = false;
      _requested.copyCurrStack(_curr);
      notifyListeners();
    } else
      _requested.pop();
  }

  /// pushes a path segment on to [_requested] stack. All calls will be ignored if [_loading] == true.
  void push(String pathSegment) {
    if (_loading) return;
    _requested.push(pathSegment);
  }

  void pushTemp(List<String> newHierarchy) {
    if (_loading) return;
    _requested.pushTemp(newHierarchy);
  }

  /// pushes a pseudo path on to [_requested] stack. All calls will be ignored if [_loading] == true.
  void pushPseudo(PseudoPage pseudoPage) {
    if (_loading) return;
    _requested.pushPseudo(pseudoPage);
  }

  /// updates [_requested] stack. All calls will be ignored if [_loading] == true.
  void setStack(List<String> hierarchy) {
    if (_loading) return;
    _requested.setStack(hierarchy);
  }

  /// Updates the [_curr] stack.
  ///
  /// Runs whenever a page is requested
  ///
  /// DETAILED DECRIPTION:
  ///
  /// Rebuilds the navigator (calling [_getPages] in the process) whenever it changes [_status]. It does so whenever it calls [notifyListeners].
  /// (In Navigator 2.0, a pre-programmed Router class listens to [AppRouterDelegate] and calls the delegate's [build] whenever the Router is notified.)
  ///
  /// All calls will be ignored if [_loading] == true. [_loading] will be set to true during this method.
  ///
  /// This method is in charge of evaluating whether or not [AppStatus.notFound] based on [_requested].
  /// If [AdditionalPage.none], then [_curr] replaces its hierarchy with [_requested]'s hierarchy.
  /// Otherwise, [_curr] stays the same.
  Future<void> _updateStack() async {
    /// If loading
    if (_loading) return;
    _loading = true;
    notifyListeners();

    List views = await getViews(_requested.hierarchy);

    /// Check if not found
    if (views != null) {
      _notFound = false;
      _curr.copyRequestedStack(_requested);
      _curr.views = views;
    } else
      _notFound = true;

    /// Finish
    _loading = false;

    notifyListeners();
  }

  /// Generates pages for the [Navigator] based on [_curr] and [_additionalPage]
  List<Page<dynamic>> _getPages() {
    // Page stack in order
    List<Page<dynamic>> pages = [];

    void addPage(Widget widget) {
      pages.add(MaterialPage(child: widget));
    }

    List hierarchy = _curr.hierarchy;

    /// Cases for handling the pages of each of the root paths
    for (int i = 0; i <= hierarchy.length; i++) {
      switch (_curr.views[i]["view"]) {
        case View.home:
          addPage(HomeView());
          break;
        case View.courses:
        case View.units:
        case View.topics:
        case View.subtopics:
          addPage(AppHomeView(collection: _curr.views[i]["reference"]));
          break;
        case View.questions:
          addPage(StudySetView(collection: _curr.views[i]["reference"]));
          break;
        case View.question:
          break;
        default:
          break;
      }
    }

    // Handle creation of pseudo-pages (views without url segments).
    switch (_curr._pseudoPage) {
      case PseudoPage.none:
        break;
      case PseudoPage.addQuestion:
        pages.add(MaterialPage(child: AddQuestionView()));
        break;
      case PseudoPage.singleQuestion:
        pages.add(MaterialPage(child: SingleQuestionView()));
        break;
    }

    // Show loading view if page is loading.
    if (_loading) {
      pages += [MaterialPage(child: LoadingView())];
      return pages;
    }

    if (_notFound == true)
      pages += [
        MaterialPage(child: RouteNotFoundView(name: Uri.base.toString()))
      ];
    return pages;
  }

  @override
  Future<void> setNewRoutePath(AppStack stack) async {
    if (_loading) return;
    if (stack.hierarchy.length > 0) _requested.setStack(stack.hierarchy);
  }
}

/// A class that parses urls into [AppStack]s, and [AppStack]s into urls.
class AppRouteInformationParser extends RouteInformationParser<AppStack> {
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
