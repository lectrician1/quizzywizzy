import 'package:quizzywizzy/constants.dart';

/// Part of the routing_constants.dart file. This should only be used by the router.dart file.
enum RouteMode {
  web,
  app,
  questionId,
  questionList,
}

/// Part of the routing_constants.dart file. This should only be used by the router.dart file.
enum AdditionalPage {
  none,
  notFound,
  questionId,
}

/// Used to push PseudoPages (views without url segments)
enum PseudoPage {
  none,
  addQuestion,
  singleQuestion,
}

/// Part of the routing_constants.dart file. This should only be used by the router.dart file.
String getRoute(List<String> hierarchy, String home) {
  String route = home;
  hierarchy.forEach((viewName) => route = "$route/$viewName");
  return route;
}

/// Part of the routing_constants.dart file. This should only be used by the router.dart file.
String appendRoute(String pathSegment, String route) {
  return "$route/$pathSegment";
}

/// Part of the routing_constants.dart file. This should only be used by the router.dart file.
String getAppRoute(List<String> hierarchy) => getRoute(hierarchy, "");
/// Part of the routing_constants.dart file. This should only be used by the router.dart file.
String getWebRoute(List<String> hierarchy) => getRoute(hierarchy.sublist(1), "");
/// Part of the routing_constants.dart file. This should only be used by the router.dart file.
List<String> get collectionNames => Constants.mainHierarchy;
/// Part of the routing_constants.dart file. This should only be used by the router.dart file.
const String urlName = Constants.docUrlName;

/// a shortcut to [Constants.appPrefix] that is part of the routing_constants service.
const String app = Constants.appPrefix;

/// a shortcut to [Constants.webPrefix] that is part of the routing_constants service.
/// 
/// Note: this actually isn't a prefix, but it is easier to code the router if we pretend that there is a web prefix.
const String web = Constants.webPrefix;

/// a shortcut to [Constants.questionIDPrefix] that is part of the routing_constants service.
const String questionID = Constants.questionIDPrefix;

/// a shortcut to [Constants.questionListPrefix] that is part of the routing_constants service.
const String questionList = Constants.questionListPrefix;