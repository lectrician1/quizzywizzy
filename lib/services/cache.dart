import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizzywizzy/services/routing_constants.dart';
import 'package:quizzywizzy/services/view_get.dart';

List<Map<String, dynamic>> home = [
  {"view": View.home}
];

Future<dynamic> getViews(List hierarchy) async {
  List<Map<String, dynamic>> views = [];
  bool notFound = false;

  /// Verify at least [hierarchy[0]] exists before calling it in the switch.
  if (hierarchy.isNotEmpty) {
    if (hierarchy[0] == "courses") {
      views.add({
        "view": View.courses,
        "reference": FirebaseFirestore.instance.collection("courses")
      });
    }

    if (hierarchy.length > 1) {
      switch (hierarchy[0]) {
        case "courses":
          views = await getCourses(hierarchy, views);
          break;
        case "questions":
          views.add({
            "reference": FirebaseFirestore.instance.collection("questions")
          });

          views = await getView(hierarchy, 2, views, View.question);

          break;

        case "sproutsets":
          views.add({
            "reference": FirebaseFirestore.instance.collection("sproutsets")
          });

          views = await getView(hierarchy, 2, views, View.sproutset);

          break;

        case "users":
          views.add(
              {"reference": FirebaseFirestore.instance.collection("users")});

          views = await getView(hierarchy, 2, views, View.user);

          break;

        /// hierarchy[0] not found
        default:
          notFound = true;
      }
    }

    if (notFound || views == null) {
      return home +
          [
            {"view": View.notFound}
          ];
    }

    return home + views;
  }
}
