/// Used to push PseudoPages (views without url segments)
enum View { 
  courses, 
  units, 
  topics, 
  subtopics, 
  home, 
  questions, 
  sproutset, 
  question, 
  user,
  notFound
}

String getRoute(List<String> hierarchy) {
  return hierarchy.join("/");
}

/// List of collections in hierarchy by level
List<String> get collectionNames => ["courses", "units", "topics", "subtopics"];
