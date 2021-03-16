import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizzywizzy/models/question_model.dart';
import 'package:quizzywizzy/services/routing_constants.dart';
import 'package:quizzywizzy/views/app_home.dart';
import 'package:quizzywizzy/views/home.dart';
import 'package:quizzywizzy/views/loading.dart';
import 'package:quizzywizzy/views/question_list.dart';
import 'package:quizzywizzy/views/question_id.dart';
import 'package:quizzywizzy/views/route_not_found.dart';

/// A class that stores a list/stack of path segments (called [hierarchy]).
///
/// Notifys any listeners whenever there is a change in the [hierarchy].
class AppStack extends ChangeNotifier {
  List<String> _hierarchy;
  List<String> get hierarchy => _hierarchy;
  AppStack({@required List<String> hierarchy}) : _hierarchy = hierarchy;
  void setStack(List<String> otherHierarchy) {
    _hierarchy = List.from(otherHierarchy);
    notifyListeners();
  }

  void copyCurrStack(AppStack curr) {
    _hierarchy = List.from(curr._hierarchy);
  }

  void copyRequestedStack(AppStack requested) {
    _hierarchy = List.from(requested._hierarchy);
  }

  void pop() {
    _hierarchy.removeLast();
    notifyListeners();
  }

  void push(String pathSegment) {
    _hierarchy.add(pathSegment);
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

  /// Local storage for url queries.
  HashMap<String, List<Map<String, dynamic>>> _visitedQueryData;

  /// Local storage for collections.
  HashMap<String, CollectionReference> _visitedCollections;

  AppStack get currentConfiguration => _requested;

  AppRouterDelegate()
      : navigatorKey = GlobalKey<NavigatorState>(),
        _requested = AppStack(hierarchy: [web]),
        _curr = AppStack(hierarchy: [web]),
        _additionalPage = AdditionalPage.none,
        _visitedQueryData = new HashMap(),
        _visitedCollections = new HashMap(),
        _loading = false {
    _requested.addListener(_updateStack);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: List.unmodifiable(_getPages()),
      /*
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        if (status == AppStatus.notFound) {
          status = AppStatus.found;
          requested.resetToCurrStack(curr);
          notifyListeners();
        } else
          requested.pop();
        return true;
      },*/
    );
  }

  bool canPop() {
    return _additionalPage != AdditionalPage.none ||
        _requested.hierarchy.length > 1;
  }

  bool isWebMode() {
    return _curr.hierarchy[0] == web;
  }

  bool isAppMode() {
    return _curr.hierarchy[0] == app;
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

  /// updates [_requested] stack. All calls will be ignored if [_loading] == true.
  void setStack(List<String> hierarchy) {
    if (_loading) return;
    _requested.setStack(hierarchy);
  }

  /// Updates the [_curr] stack.
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
    bool notFound = false;
    RouteMode mode = RouteMode.app;
    _additionalPage = AdditionalPage.none;
    // use an else if statement in the for loop if you want a change in mode
    // any changes in mode will cause any subsequent path segments in the requested hierarchy to be evaluated based on the mode, unless if another else if statement changes the mode later on
    for (int i = 0; i < _requested.hierarchy.length; i++) {
      if (notFound) break;
      if (i == 0 && _requested.hierarchy[i] == web) {
        // if 0th hierarchy && current path segment is web:
        mode = RouteMode.web;
      } else if (i == 0 && _requested.hierarchy[i] == app) {
        // if 0th hierarchy && current path segment is app:
        String key = getRoute(_requested.hierarchy.sublist(0, i + 1), "");
        if (!_visitedCollections.containsKey(key)) {
          _visitedCollections[key] =
              FirebaseFirestore.instance.collection(collectionNames[0]);
          QuerySnapshot query = await _visitedCollections[key].get();
          _visitedQueryData[key] = [];
          query.docs.forEach((doc) {
            _visitedQueryData[key].add(doc.data());
            _visitedCollections[appendRoute(doc.data()[urlName], key)] =
                doc.reference.collection(collectionNames[1]);
          });
        }
        mode = RouteMode.app;
      } else if (i == 1 &&
          _requested.hierarchy[0] == app &&
          _requested.hierarchy[i] == questionID) {
        // if 1st hierarchy && 0th path segment is app && current path segment is questionID:
        if (_requested.hierarchy.length != 3) notFound = true;
        mode = RouteMode.questionId;
      } else if (i > 1 &&
          _requested.hierarchy[0] == app &&
          _requested.hierarchy[i] == questionList) {
        // if past 1st hierarchy && 0th path segment is app && current path segment is questionList:
        mode = RouteMode.questionList;
      } else {
        switch (mode) {
          case RouteMode.web:
            notFound = true;
            break;
          case RouteMode.app:
            String key = getRoute(_requested.hierarchy.sublist(0, i + 1), "");
            if (_visitedCollections.containsKey(key)) {
              if (!_visitedQueryData.containsKey(key)) {
                QuerySnapshot query = await _visitedCollections[key].get();
                _visitedQueryData[key] = [];
                query.docs.forEach((doc) {
                  _visitedQueryData[key].add(doc.data());
                  if (i + 1 < collectionNames.length)
                    _visitedCollections[appendRoute(doc.data()[urlName], key)] =
                        doc.reference.collection(collectionNames[i + 1]);
                });
              }
            } else {
              notFound = true;
            }
            break;
          case RouteMode.questionId:
            _additionalPage = AdditionalPage.questionId;
            break;
          case RouteMode.questionList:
            notFound = true;
            break;
        }
      }
    }
    if (notFound) _additionalPage = AdditionalPage.notFound;
    if (_additionalPage == AdditionalPage.none)
      _curr.copyRequestedStack(_requested);
    _loading = false;
    notifyListeners();
  }

  /// Generates pages for the [Navigator] based on [_curr] and [_additionalPage]
  List<Page<dynamic>> _getPages() {
    List<Page<dynamic>> pages = [];
    RouteMode mode = RouteMode.app;
    // the structure of the if else statements & switch statement of this for loop should match exactly with the for loop in _updateStack
    for (int i = 0; i < _curr.hierarchy.length; i++) {
      if (i == 0 && _curr.hierarchy[i] == web) {
        // if 0th hierarchy && current path segment is web:
        pages.add(MaterialPage(child: HomeView()));
        mode = RouteMode.web;
      } else if (i == 0 && _curr.hierarchy[i] == app) {
        // if 0th hierarchy && current path segment is app:
        String key = getRoute(_curr.hierarchy.sublist(0, i + 1), "");
        pages.add(MaterialPage(
            child: AppHomeView(
                appHierarchy: [], queryData: _visitedQueryData[key])));
        mode = RouteMode.app;
      } else if (i == 1 &&
          _requested.hierarchy[0] == app &&
          _requested.hierarchy[i] == questionID) {
        // if 1st hierarchy && 0th path segment is app && current path segment is questionID:
        mode = RouteMode.questionId;
      } else if (i > 1 &&
          _requested.hierarchy[0] == app &&
          _requested.hierarchy[i] == questionList) {
        // if past 1st hierarchy && 0th path segment is app && current path segment is questionList:
        pages.add(MaterialPage(
            child: QuestionListView(
                appHierarchy: _curr.hierarchy.sublist(1, i + 1))));
        mode = RouteMode.questionList;
      } else {
        switch (mode) {
          case RouteMode.web:
            break;
          case RouteMode.app:
            String key = getRoute(_curr.hierarchy.sublist(0, i + 1), "");
            pages.add(MaterialPage(
                //key: ValueKey(key),
                child: AppHomeView(
                    appHierarchy: _curr.hierarchy.sublist(1, i + 1),
                    queryData: _visitedQueryData[key])));
            break;
          case RouteMode.questionId:
            break;
          case RouteMode.questionList:
            break;
        }
      }
    }
    if (_loading) {
      pages += [
        MaterialPage(
            //key: ValueKey(getRoute(_curr.hierarchy, "loading")),
            child: LoadingView())
      ];
      return pages;
    }
    switch (_additionalPage) {
      case AdditionalPage.none:
        break;
      case AdditionalPage.notFound:
        pages += [
          MaterialPage(
              //key: ValueKey(getRoute(_curr.hierarchy, "not-found")),
              child: RouteNotFoundView(name: Uri.base.toString()))
        ];
        break;
      case AdditionalPage.questionId:
        pages.add(MaterialPage(
            child: QuestionIDView(
                questionData: QuestionModel.multipleChoice(
                    questionText:
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim ",
                    choices: [
                      "quis nostrud exercitation ullamco",
                      "reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."
                    ],
                    answer: 0,
                    explanations: [
                      "Excepteur sint occaecat cupidatat non proident",
                      "sunt in culpa qui officia deserunt mollit anim id est laborum."
                    ]))));
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
    if (uri.pathSegments.length >= 1 && uri.pathSegments[0] == app)
      return AppStack(hierarchy: uri.pathSegments);
    return AppStack(hierarchy: [web] + uri.pathSegments);
  }

  @override
  RouteInformation restoreRouteInformation(AppStack page) {
    RouteInformation route;
    switch (page.hierarchy[0]) {
      case web:
        route = RouteInformation(location: getWebRoute(page.hierarchy));
        break;
      case app:
        route = RouteInformation(location: getAppRoute(page.hierarchy));
        break;
    }
    return route;
  }
}
