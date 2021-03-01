const String title = "QuizzyWizzy";

const List<String> domains = ["stu.naperville203.org"];
const String homeRouteName = "home";
const String gettingStartedRouteName = "getting-started";

String getHomeRoute() => "/$homeRouteName";
String getGettingStartedRoute() => "/$gettingStartedRouteName";
String getCourseRoute(dynamic course) => getHomeRoute() + "/$course";