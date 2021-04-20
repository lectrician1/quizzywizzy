import 'dart:collection';

/// Needed to create views
import 'package:flutter/material.dart';

/// Firestore
/// Needed for storing hierarchy data locally
import 'package:cloud_firestore/cloud_firestore.dart';

/// Cache
import 'package:quizzywizzy/services/cache.dart';

/// Routing constants
import 'package:quizzywizzy/services/routing_constants.dart';

/// Handy functions
import 'package:quizzywizzy/functions.dart';

/// Views
import 'package:quizzywizzy/views/add_question.dart';
import 'package:quizzywizzy/views/app_home.dart';
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
  List<String> get hierarchy => _hierarchy;

  PseudoPage _pseudoPage = PseudoPage.none;
  PseudoPage get pseudoPage => _pseudoPage;

  AppStack({@required List<String> hierarchy}) : _hierarchy = hierarchy;

  /// Set a new hierarchy
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
    else
      _pseudoPage = PseudoPage.none;
    notifyListeners();
  }

  /// Add a page to the hierarchy and view stack
  void push(String pathSegment) {
    _hierarchy.add(pathSegment);
    _pseudoPage = PseudoPage.none;
    notifyListeners();
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
  AdditionalPage _additionalPage;

  /// Represents whether or not [_updateStack] has already been called.
  bool _loading;

  Cache _cache;

  AppStack get currentConfiguration => _requested;

  /// Main constructor that initializes all of the needed AppStacks for the router
  AppRouterDelegate()
      : navigatorKey = GlobalKey<NavigatorState>(),
        _requested = AppStack(hierarchy: []),

        /// Courses needs to be in the current heirarchy or else getPages will never know what the "first page" is.
        /// This is temporary until an actual homepage is created and getPages can account for no first hierarchy
        _curr = AppStack(hierarchy: ["courses"]),
        _additionalPage = AdditionalPage.none,

        /// Initialize local storage
        _cache = new Cache(),
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
    return _additionalPage != AdditionalPage.none ||
        _requested.hierarchy.length > 1;
  }

  /// pops [_requested] stack. All calls will be ignored if [_loading] == true.
  void pop() {
    if (_loading) return;
    if (_additionalPage != AdditionalPage.none) {
      _additionalPage = AdditionalPage.none;
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
    if (_loading) return;
    _loading = true;
    notifyListeners();

    /// Always set that there is no additional page when updateStack is called.
    _additionalPage = AdditionalPage.none;

    if (await _cache.storeDocs(_requested.hierarchy))
      _additionalPage = AdditionalPage.notFound;

    if (_additionalPage == AdditionalPage.none)
      _curr.copyRequestedStack(_requested);
    _loading = false;

    notifyListeners();
  }

  /// Generates pages for the [Navigator] based on [_curr] and [_additionalPage]
  List<Page<dynamic>> _getPages() {
    // Page stack in order
    List<Page<dynamic>> pages = [];

    List hierarchy = _curr.hierarchy;

    List hierarchyLevels = _cache.getLevels(hierarchy);

    print(hierarchyLevels);

    /// Cases for handling the pages of each of the root paths
    switch (hierarchy[0]) {
      case "courses":

        /// Add heirarchy pages
        for (Map level in hierarchyLevels) {
          if (level["view"] == "questions") {
            pages.add(MaterialPage(
                child: StudySetView(questionsDocs: level["documents"])));
          } else {
            pages.add(MaterialPage(
                child: AppHomeView(
                    level: level["view"],
                    docs: level["documents"]
                        .entries
                        .map((doc) => doc.value)
                        .toList())));
          }
        }
        break;
      case "question":
        break;
      case "sproutset":
        break;
      case "user":
        break;
      default:
        print("oh");
        break;
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

    switch (_additionalPage) {
      case AdditionalPage.none:
        break;
      case AdditionalPage.notFound:
        pages += [
          MaterialPage(child: RouteNotFoundView(name: Uri.base.toString()))
        ];
        break;
    }
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
