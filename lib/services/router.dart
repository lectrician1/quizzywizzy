import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizzywizzy/services/routing_constants.dart';
import 'package:quizzywizzy/views/add_question.dart';
import 'package:quizzywizzy/views/app_home.dart';
import 'package:quizzywizzy/views/loading.dart';
import 'package:quizzywizzy/views/single_question.dart';
import 'package:quizzywizzy/views/study_set.dart';
import 'package:quizzywizzy/views/route_not_found.dart';

/// A class that stores a list/stack of path segments (called [hierarchy]).
///
/// Notifys any listeners whenever there is a change in the [hierarchy].
class AppStack extends ChangeNotifier {
  List<String> _hierarchy;
  List<String> get hierarchy => _hierarchy;

  PseudoPage _pseudoPage = PseudoPage.none;
  PseudoPage get pseudoPage => _pseudoPage;

  AppStack({@required List<String> hierarchy}) : _hierarchy = hierarchy;

  void setStack(List<String> otherHierarchy) {
    _hierarchy = List.from(otherHierarchy);
    _pseudoPage = PseudoPage.none;
    notifyListeners();
  }

  void copyCurrStack(AppStack curr) {
    _hierarchy = List.from(curr._hierarchy);
    _pseudoPage = curr._pseudoPage;
  }

  void copyRequestedStack(AppStack requested) {
    _hierarchy = List.from(requested._hierarchy);
    _pseudoPage = requested._pseudoPage;
  }

  void pop() {
    if (_pseudoPage == PseudoPage.none)
      _hierarchy.removeLast();
    else
      _pseudoPage = PseudoPage.none;
    notifyListeners();
  }

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

  /// Local storage for url queries.
  ///
  /// Key is the reference to the hierarcy document that has been visited
  /// Value is the document data itself
  HashMap<String, List<Map<String, dynamic>>> _visitedQueryData;

  /// Local storage for collections.
  HashMap<String, CollectionReference> _visitedCollections;

  AppStack get currentConfiguration => _requested;

  AppRouterDelegate()
      : navigatorKey = GlobalKey<NavigatorState>(),
        _requested = AppStack(hierarchy: []),
        _curr = AppStack(hierarchy: []),
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
    _additionalPage = AdditionalPage.none;
    List<String> _hierarchy = _requested.hierarchy;

    switch (_hierarchy[0]) {
      case "courses":
        for (int i = 1; i < _hierarchy.length; i++) {
          String key = getRoute(_hierarchy.sublist(0, i + 1), "");
          print(key);

          // If the path has not been visited
          if (!_visitedCollections.containsKey(key)) {
            _visitedCollections[key] =
                FirebaseFirestore.instance.collection(collectionNames[0]);

            QuerySnapshot query = await _visitedCollections[key].get();

            _visitedQueryData[key] = [];

            // Add each document in hierarchy collection to _visitedQueryData
            query.docs.forEach((doc) {
              _visitedQueryData[key].add(doc.data());

              _visitedCollections[appendRoute(doc.data()["name"], key)] =
                  doc.reference.collection(collectionNames[i + 1]);
            });
          } else {
            notFound = true;
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
        notFound = true;
        break;
    }

    // use an else if statement in the for loop if you want a change in mode
    // any changes in mode will cause any subsequent path segments in the requested hierarchy to be evaluated based on the mode, unless if another else if statement changes the mode later on
    /*
    for (int i = 0; i < _hierarchy.length; i++) {
      if (notFound) break;

      // if 0th hierarchy && current path segment is web
      if (i == 0 && _hierarchy[i] == web) {
        mode = RouteMode.web;
      }

      else if 
      // if 0th hierarchy && current path segment is app
      else if (i == 0 && _hierarchy[i] == app) {
        String key = getRoute(_hierarchy.sublist(0, i + 1), "");

        // If the 
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
      } 
      
      else {
        switch (mode) {
          case RouteMode.web:
            notFound = true;
            break;
          case RouteMode.app:
            String key = getRoute(_hierarchy.sublist(0, i + 1), "");
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
        }
      }
    }
    */

    if (notFound) _additionalPage = AdditionalPage.notFound;

    if (_additionalPage == AdditionalPage.none)
      _curr.copyRequestedStack(_requested);
    _loading = false;

    notifyListeners();
  }

  /// Generates pages for the [Navigator] based on [_curr] and [_additionalPage]
  List<Page<dynamic>> _getPages() {
    // Page stack in order
    List<Page<dynamic>> pages = [];

    // Cases for handling the pages of each of the root paths
    switch (_curr.hierarchy[0]) {
      case "courses":
        for (int i = 1; i < _curr.hierarchy.length; i++) {
          print(_curr.hierarchy);
          List hierarchy = _curr.hierarchy.sublist(1, i + 1);
          String key = getRoute(hierarchy, "");

          pages.add(MaterialPage(
              //key: ValueKey(key),
              child: AppHomeView(
                  appHierarchy: hierarchy, queryData: _visitedQueryData[key])));
        }
        break;
      case "question":
        break;
      case "sproutset":
        break;
      case "user":
        break;
      default:
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
    route = RouteInformation(location: getAppRoute(page.hierarchy));
    return route;
  }
}
