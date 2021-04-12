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

/// Returns the route
/// 
/// e.g. [courses, AP Calculus,  Unit 1] -> "courses/AP Calculus/Unit 1"
String getRoute(List<String> hierarchy) {
  return hierarchy.join("/");
}

/// Adds a pathSegment to a route
String appendRoute(String route, String pathSegment) {
  return "$route/$pathSegment";
}

/// List of collections in hierarchy by level
List<String> get collectionNames => ["courses", "units", "topics", "subtopics"];