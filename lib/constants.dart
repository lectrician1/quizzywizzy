const String title = "QuizzyWizzy";

const String homeRouteName = "home";
const String gettingStartedRouteName = "getting-started";

String getHomeRoute() => "/$homeRouteName";
String getGettingStartedRoute() => "/$gettingStartedRouteName";
String getCourseRoute(dynamic course) => getHomeRoute() + "/$course";