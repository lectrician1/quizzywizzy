import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizzywizzy/models/question_model.dart';
import 'package:quizzywizzy/services/routing_constants.dart';
import 'package:quizzywizzy/views/app_home.dart';
import 'package:quizzywizzy/views/home.dart';
import 'package:quizzywizzy/views/loading.dart';
import 'package:quizzywizzy/views/question_id.dart';
import 'package:quizzywizzy/views/route_not_found.dart';

class AppStack extends ChangeNotifier {
  List<String> hierarchy;
  AppStack({@required this.hierarchy});
  void setStack(List<String> otherHierarchy) {
    hierarchy = List.from(otherHierarchy);
    notifyListeners();
  }

  void pop() {
    hierarchy.removeLast();
    notifyListeners();
  }

  void push(String pathSegment) {
    hierarchy.add(pathSegment);
    notifyListeners();
  }
}

class AppRouterDelegate extends RouterDelegate<AppStack>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppStack> {
  final GlobalKey<NavigatorState> navigatorKey;
  AppStack requested;
  AppStack curr;
  AppStatus status;
  HashMap<String, List<Map<String, dynamic>>> visitedQueryData;
  HashMap<String, CollectionReference> visitedCollections;
  AppStack get currentConfiguration => requested;

  AppRouterDelegate()
      : navigatorKey = GlobalKey<NavigatorState>(),
        requested = AppStack(hierarchy: [web]),
        curr = AppStack(hierarchy: [web]),
        status = AppStatus.found,
        visitedQueryData = new HashMap(),
        visitedCollections = new HashMap() {
    requested.addListener(_updateStack);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: List.unmodifiable(_getPages()),
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        if (status == AppStatus.notFound) {
          status = AppStatus.found;
          requested.hierarchy = List.from(curr.hierarchy);
          notifyListeners();
        } else
          requested.pop();
        return true;
      },
    );
  }

  bool canPop() {
    return status == AppStatus.notFound || requested.hierarchy.length > 1;
  }

  bool isWebMode() {
    return curr.hierarchy[0] == web;
  }

  bool isAppMode() {
    return curr.hierarchy[0] == app;
  }

  void pop() {
    if (status == AppStatus.notFound) {
      status = AppStatus.found;
      requested.hierarchy = List.from(curr.hierarchy);
      notifyListeners();
    } else
      requested.pop();
  }

  void push(String pathSegment) {
    requested.push(pathSegment);
  }

  void setStack(List<String> hierarchy) {
    requested.setStack(hierarchy);
  }

  Future<void> _updateStack() async {
    if (status != AppStatus.loading) {
      status = AppStatus.loading;
      notifyListeners();
      bool notFound = false;
      RouteMode mode = RouteMode.app;
      for (int i = 0; i < requested.hierarchy.length; i++) {
        if (notFound) break;
        if (i == 0 && requested.hierarchy[i] == web) {
          // "web" at hierarchy 0
          mode = RouteMode.web;
        } else if (i == 0 && requested.hierarchy[i] == app) {
          // "app" at hierarchy 0
          String key = getRoute(requested.hierarchy.sublist(0, i + 1), "");
          if (!visitedCollections.containsKey(key)) {
            visitedCollections[key] =
                FirebaseFirestore.instance.collection(collectionNames[0]);
            QuerySnapshot query = await visitedCollections[key].get();
            visitedQueryData[key] = [];
            query.docs.forEach((doc) {
              visitedQueryData[key].add(doc.data());
              visitedCollections[appendRoute(doc.data()[urlName], key)] =
                  doc.reference.collection(collectionNames[1]);
            });
          }
          mode = RouteMode.app;
        } else if (i == 1 &&
            requested.hierarchy[0] == app &&
            requested.hierarchy[i] == questionID) {
          if (requested.hierarchy.length != 3) notFound = true;
          mode = RouteMode.questionId;
        } else {
          switch (mode) {
            case RouteMode.web:
              notFound = true;
              break;
            case RouteMode.app:
              String key = getRoute(requested.hierarchy.sublist(0, i + 1), "");
              if (visitedCollections.containsKey(key)) {
                if (!visitedQueryData.containsKey(key)) {
                  QuerySnapshot query = await visitedCollections[key].get();
                  visitedQueryData[key] = [];
                  query.docs.forEach((doc) {
                    visitedQueryData[key].add(doc.data());
                    if (i + 1 < collectionNames.length)
                      visitedCollections[
                              appendRoute(doc.data()[urlName], key)] =
                          doc.reference.collection(collectionNames[i + 1]);
                  });
                }
              } else {
                notFound = true;
              }
              break;
            case RouteMode.questionId:
              break;
            case RouteMode.questions:
              break;
          }
        }
      }
      if (notFound) {
        status = AppStatus.notFound;
      } else {
        status = AppStatus.found;
        curr.hierarchy = List.from(requested.hierarchy);
      }
      notifyListeners();
    }
  }

  List<Page<dynamic>> _getPages() {
    List<Page<dynamic>> pages = [];
    RouteMode mode = RouteMode.app;
    for (int i = 0; i < curr.hierarchy.length; i++) {
      if (i == 0 && curr.hierarchy[i] == web) {
        pages.add(MaterialPage(
            //key: ValueKey(getRoute(curr.hierarchy.sublist(0, i + 1), "")),
            child: HomeView()));
        mode = RouteMode.web;
      } else if (i == 0 && curr.hierarchy[i] == app) {
        String key = getRoute(curr.hierarchy.sublist(0, i + 1), "");
        pages.add(MaterialPage(
            //key: ValueKey(key),
            child: AppHomeView(
                appHierarchy: [], queryData: visitedQueryData[key])));
        mode = RouteMode.app;
      } else if (i == 1 &&
          requested.hierarchy[0] == app &&
          requested.hierarchy[i] == questionID) {
        mode = RouteMode.questionId;
      } else {
        switch (mode) {
          case RouteMode.web:
            break;
          case RouteMode.app:
            String key = getRoute(curr.hierarchy.sublist(0, i + 1), "");
            pages.add(MaterialPage(
                //key: ValueKey(key),
                child: AppHomeView(
                    appHierarchy: curr.hierarchy.sublist(1, i + 1),
                    queryData: visitedQueryData[key])));
            break;
          case RouteMode.questionId:
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
          case RouteMode.questions:
            break;
        }
      }
    }
    switch (status) {
      case AppStatus.found:
        break;
      case AppStatus.loading:
        pages += [
          MaterialPage(
              key: ValueKey(getRoute(curr.hierarchy, "loading")),
              child: LoadingView())
        ];
        break;
      case AppStatus.notFound:
        pages += [
          MaterialPage(
              key: ValueKey(getRoute(curr.hierarchy, "not-found")),
              child: RouteNotFoundView(name: Uri.base.toString()))
        ];
        break;
    }
    return pages;
  }

  @override
  Future<void> setNewRoutePath(AppStack stack) async {
    if (status != AppStatus.loading && stack.hierarchy.length > 0)
      requested.setStack(stack.hierarchy);
  }
}

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
