/// Part of the routing_constants.dart file. This should only be used by the router.dart file.
enum AdditionalPage {
  none,
  notFound
}

/// Used to push PseudoPages (views without url segments)
enum PseudoPage {
  none,
  addQuestion,
  singleQuestion,
}

/// Part of the routing_constants.dart file. This should only be used by the router.dart file.
/// 
/// Returns the route in the format of a Firestore reference
String getRoute(List<String> hierarchy, String home) {
  String route = home;
  hierarchy.forEach((viewName) => route = "$route/$viewName");
  return route;
}

/// Part of the routing_constants.dart file. This should only be used by the router.dart file.
/// 
/// Adds a route to the pathSegment
String appendRoute(String pathSegment, String route) {
  return "$route/$pathSegment";
}

/// Part of the routing_constants.dart file. This should only be used by the router.dart file.
String getAppRoute(List<String> hierarchy) => getRoute(hierarchy, "");

/// Part of the routing_constants.dart file. This should only be used by the router.dart file.
String getWebRoute(List<String> hierarchy) => getRoute(hierarchy.sublist(1), "");

/// Part of the routing_constants.dart file. This should only be used by the router.dart file.
/// 
/// List of collections in hierarchy by level
List<String> get collectionNames => ["courses", "units", "topics", "subtopics"];