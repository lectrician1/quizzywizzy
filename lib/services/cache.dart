import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizzywizzy/services/routing_constants.dart';

enum View { courses, units, topics, subtopics, home, questions, question }

List<View> views = View.values;

Future<dynamic> getViews(List hierarchy) async {
  List<Map<String, dynamic>> viewReferences = [{
    "view": View.home
  }];

  if (hierarchy.isNotEmpty) {
    switch (hierarchy[0]) {
      case "courses":
        viewReferences.add({
          "view": View.courses,
          "reference": FirebaseFirestore.instance.collection("courses")
        });

        /// Level iterator
        int level = 0;

        /// Check each given level of the hierarchy to see if it has a valid page (Firestore document)
        while (level < hierarchy.length) {
          /// Get the documents in the collection
          QuerySnapshot query = await viewReferences[level + 1]["reference"].get();

          /// If document has been found for this level
          bool foundDoc = false;

          /// Document iterator
          int i = 0;

          /// Check each document in the level if it has the url of the next level.
          /// That means the level is a valid page.
          while (i < query.docs.length) {
            Map doc = query.docs[i].data();

            /// If the url segment equals the doc url, then the page exists
            if (hierarchy[level] == doc["url"]) {
              foundDoc = true;

              if (doc["questions"] != null) {
                viewReferences[level + 2] = {
                  "view": View.questions,
                  "reference": viewReferences[level]["reference"]
                      .doc(query.docs[i].id)
                      .collection(collectionNames[level])
                };
              }
              {
                viewReferences[level + 2] = {
                  "view": views[level + 1],
                  "reference": viewReferences[level]["reference"]
                      .doc(query.docs[i].id)
                      .collection(collectionNames[level])
                };
              }

              /// Stop checking documents
              break;
            }

            /// Advance to the next document
            i++;
          }

          if (foundDoc)

            /// Advance to the next level
            level++;
          else

            /// If a document was never found in the collection, return false.
            return null;
        }
        break;
      case "questions":

        /// Check if document id is provided
        if (hierarchy[1] != null) {
          /// Get document snapshot to see if the doc exists
          DocumentSnapshot snapshot = await FirebaseFirestore.instance
              .doc("questions/${hierarchy[1]}")
              .get();

          /// Return true if question document exists
          if (snapshot.exists)
            viewReferences.add({
              "view": View.question,
              "reference":
                  FirebaseFirestore.instance.doc("questions/${hierarchy[1]}")
            });
        }
        break;
      
      /// Hierarcy[0] not found
      default:
        return null;
    }
  }
  return viewReferences;
}
