import 'package:quizzywizzy/constants.dart' as Constants;

enum RouteMode {
  web,
  app,
  questionId,
  questions,
}

enum AppStatus {
  found,
  loading,
  notFound,
}

String getRoute(List<String> hierarchy, String home) {
  String route = home;
  hierarchy.forEach((viewName) => route = "$route/$viewName");
  return route;
}

String getAppRoute(List<String> hierarchy) => getRoute(hierarchy, "");
String getWebRoute(List<String> hierarchy) => getRoute(hierarchy.sublist(1), "");
List<String> get collectionNames => Constants.mainHierarchy;
const String appPrefix = Constants.appHomeRouteName;
const String webPrefix = Constants.webHomeRouteNamePseudo;