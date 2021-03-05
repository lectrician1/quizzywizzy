const String title = "QuizzyWizzy";

const List<String> domains = ["stu.naperville203.org"];
const String homeRouteName = "home";
const String gettingStartedRouteName = "getting-started";
const List<String> mainHierarchy = ["courses", "units", "topics", "subtopics"];

String getRoute(List<String> hierarchy) {
  String route = "/$homeRouteName";
  hierarchy.forEach((viewName) => route = "$route/$viewName");
  return route;
}

String getRouteBackButton(List<String> hierarchy) {
  if (hierarchy.length == 0) return "";
  String route = "/$homeRouteName";
  for (int i=0; i<hierarchy.length-1; i++) route = "$route/${hierarchy[i]}";
  return route;
}

String getRouteFluro(List<String> hierarchy) {
  String route = "/$homeRouteName";
  hierarchy.forEach((viewName) => route = "$route/:$viewName");
  return route;
}