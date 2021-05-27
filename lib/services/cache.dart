import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizzywizzy/services/routing_constants.dart';

List<View> viewTypes = View.values;
List<Map<String, dynamic>> home = [
  {"view": View.home}
];

Future<dynamic> getViews(List hierarchy) async {
  List<Map<String, dynamic>> views = [];
  bool notFound = false;

  /// Verify at least [hierarchy[0]] exists before calling it in the switch.
  if (hierarchy.isNotEmpty) {
    switch (hierarchy[0]) {
      case "courses":
        views.add({
          "view": View.courses,
          "reference": FirebaseFirestore.instance.collection("courses")
        });

        /// Level iterator
        int level = 0;

        /// Check each given level of the hierarchy to see
        /// if it has a valid page (Firestore document)
        while (level < hierarchy.length - 1) {
          QuerySnapshot query;

          try {
            query = await views[level]["reference"]
                .get(/*GetOptions(source: Source.cache)*/);
          } catch (e) {
            print(e);
            query = views[level]["reference"]
                .get(GetOptions(source: Source.server));
          }

          print("Is from cache? ${query.metadata.isFromCache}");

          /// If document has been found for this level
          bool foundLevel = false;

          /// Document iterator
          int i = 0;

          /// Check each document in the level if it has the url of the next level.
          /// That means the level is a valid page.
          while (i < query.docs.length) {
            Map<String, dynamic> doc = query.docs[i].data();

            /// If the url segment equals the doc url.
            if (hierarchy[level + 1] == doc["url"]) {
              /// The has been found and the page is availible.
              foundLevel = true;

              /// Add next level [View] and [CollectionReference] to [views]

              /// Add [View.questions] "questions" field is present in doc
              if (doc["questions"] != null && doc["questions"] == true) {
                views.add({
                  "view": View.questions,
                  "reference": views[level]["reference"]
                });
              }

              /// Next level [View]
              else {
                views.add({
                  "view": viewTypes[level + 1],
                  "reference": views[level]["reference"]
                      .doc(query.docs[i].id)
                      .collection(collectionNames[level + 1])
                });
              }

              /// Stop documents iterator because doc is found.
              /// Prevents unecessary computation.
              /// It's also why this is a while loop and not a for loop
              /// (it can break).
              break;
            }

            /// Advance to the next document
            i++;
          }

          if (foundLevel)

            /// Advance to the next level
            level++;
          else {
            /// Declare notFound because doc was never found for the level
            /// Do this now to cut down on unecessary further computation
            notFound = true;

            /// Stop levels iterator
            break;
          }
        }
        break;

      case "questions":

        /// Check if document id is provided
        if (hierarchy.length == 2) {
          /// Temporary question page
          if (hierarchy[1] == "1") {
            views.add({"view": View.question, "reference": FirebaseFirestore.instance.doc("/questions/47bSFU9INGhMIUHlp1Ev")});
          }

          /*
          /// Get document snapshot to see if the doc exists
          DocumentSnapshot snapshot = await FirebaseFirestore.instance
              .doc("questions/${hierarchy[1]}")
              .get();

          /// Return true if question document exists
          if (snapshot.exists)
            views.add({
              "view": View.question,
              "reference":
                  FirebaseFirestore.instance.doc("questions/${hierarchy[1]}")
            });
          */
        }

        else {

          /// Not a valid "/questions" path
          notFound = true;
          
        }
        break;

      /// hierarchy[0] not found
      default:
        notFound = true;
    }
  }

  if (notFound) {
    return home +
        [
          {"view": View.notFound}
        ];
  }

  return home + views;
}
