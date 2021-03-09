import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizzywizzy/services/routing_constants.dart';
import 'package:quizzywizzy/views/app_home.dart';
import 'package:quizzywizzy/views/home.dart';
import 'package:quizzywizzy/views/loading.dart';
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
  HashMap<String, QuerySnapshot> visitedQueries;
  HashMap<String, QuerySnapshot> visitedUrlNameQueries;
  HashMap<String, CollectionReference> visitedCollections;
  AppStack get currentConfiguration => requested;

  AppRouterDelegate()
      : navigatorKey = GlobalKey<NavigatorState>(),
        requested = AppStack(hierarchy: ["web"]),
        curr = AppStack(hierarchy: ["web"]),
        status = AppStatus.found,
        visitedQueries = new HashMap(),
        visitedUrlNameQueries = new HashMap(),
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
        if (i == 0 && requested.hierarchy[i] == webPrefix) {
          // "web" at hierarchy 0
          mode = RouteMode.web;
        } else if (i == 0 && requested.hierarchy[i] == appPrefix) {
          // "app" at hierarchy 0
          String key = getRoute(requested.hierarchy.sublist(0, i + 1), "");
          if (!visitedQueries.containsKey(key))
            visitedCollections[key] =
                FirebaseFirestore.instance.collection(collectionNames[0]);
          visitedQueries[key] = await visitedCollections[key].get();
          mode = RouteMode.app;
        } else {
          switch (mode) {
            case RouteMode.web:
              notFound = true;
              break;
            case RouteMode.app:
              String key = getRoute(requested.hierarchy.sublist(0, i + 1), "");
              if (!visitedUrlNameQueries.containsKey(key)) {
                String prevKey =
                    getRoute(requested.hierarchy.sublist(0, i), "");
                QuerySnapshot newQuery = await visitedCollections[prevKey]
                    .where("url name", isEqualTo: this.requested.hierarchy[i])
                    .limit(1)
                    .get();
                if (newQuery.docs.length == 0) {
                  notFound = true;
                } else {
                  visitedUrlNameQueries[key] = newQuery;
                  visitedCollections[key] =
                      newQuery.docs[0].reference.collection(collectionNames[i]);
                  visitedQueries[key] = await visitedCollections[key].get();
                }
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
      if (i == 0 && curr.hierarchy[i] == webPrefix) {
        pages.add(MaterialPage(
            //key: ValueKey(getRoute(curr.hierarchy.sublist(0, i + 1), "")),
            child: HomeView()));
        mode = RouteMode.web;
      } else if (i == 0 && curr.hierarchy[i] == appPrefix) {
        String key = getRoute(curr.hierarchy.sublist(0, i + 1), "");
        pages.add(MaterialPage(
            //key: ValueKey(key),
            child: AppHomeView(appHierarchy: [], query: visitedQueries[key])));
        mode = RouteMode.app;
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
                    query: visitedQueries[key])));
            break;
          case RouteMode.questionId:
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
    if (uri.pathSegments.length >= 1 && uri.pathSegments[0] == appPrefix)
      return AppStack(hierarchy: uri.pathSegments);
    return AppStack(hierarchy: [webPrefix] + uri.pathSegments);
  }

  @override
  RouteInformation restoreRouteInformation(AppStack page) {
    RouteInformation route;
    switch (page.hierarchy[0]) {
      case webPrefix:
        route = RouteInformation(location: getWebRoute(page.hierarchy));
        break;
      case appPrefix:
        route = RouteInformation(location: getAppRoute(page.hierarchy));
        break;
    }
    return route;
  }
}
