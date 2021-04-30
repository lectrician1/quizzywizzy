/// Used to push PseudoPages (views without url segments)
enum PseudoPage {
  none,
  addQuestion,
  singleQuestion,
}

String getRoute(List<String> hierarchy) {
  return hierarchy.join("/");
}

String getFirestorePath(List<String> hierarchy) {
  String path;
  switch (hierarchy[0]) {
    case "courses":
      for (int i = 0; i < hierarchy.length; i++) {
        path += 
      }
  }
  
}

/// List of collections in hierarchy by level
List<String> get collectionNames => ["courses", "units", "topics", "subtopics"];
