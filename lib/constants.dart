class Constants {
  static String getHost(bool isAndroid) => isAndroid ? '10.0.2.2' : 'localhost';
  static const int functionsPort = 5001;
  static String getFunctionsHost(bool isAndroid) => "http://${getHost(isAndroid)}:$functionsPort";
  static const int firestorePort = 4040;
  static String getFirestoreHost(bool isAndroid) => "${getHost(isAndroid)}:$firestorePort";
  static const bool emulatorUsed = false;

  static const String title = "StudySprout";

  static const List<String> domains = [
    "stu.naperville203.org",
    "naperville203.org"
  ];
  static const String appPrefix = "app";
  static const String webPrefix = "web";
  static const String questionIDPrefix = "question-id";
  static const String questionListPrefix = "questions";
  static const List<String> mainHierarchy = [
    "courses",
    "units",
    "topics",
    "subtopics"
  ];

  static const String docName = "name";
  static const String docUrlName = "url";
  
  static const double constraintWidth = 1150;
}
