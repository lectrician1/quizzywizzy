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

String getRoute(List<String> hierarchy) {
  return hierarchy.join("/");
}

/// List of collections in hierarchy by level
List<String> get collectionNames => ["courses", "units", "topics", "subtopics"];
