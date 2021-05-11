import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizzywizzy/services/routing_constants.dart';

List<View> viewTypes = View.values;

Future<List<Map<String, dynamic>>> getCourses(
    List<String> hierarchy, List<Map> views) async {
  /// Level iterator
  int level = 0;

  /// Check each given level of the hierarchy to see
  /// if it has a valid page (Firestore document)
  while (level < hierarchy.length - 1) {
    if (views[level]["view"] == View.questions) {
      views = await getView(hierarchy, level, views, View.question);
    } else {
      QuerySnapshot query;

      try {
        query = await views[level]["reference"]
            .get(GetOptions(source: Source.cache));
        if (query == null)
          query =
              views[level]["reference"].get(GetOptions(source: Source.server));
      } catch (e) {
        print(e);
        query =
            views[level]["reference"].get(GetOptions(source: Source.server));
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

          /// Add [View.questions] "questions" field is present and true in doc
          if (doc["questions"] != null && doc["questions"] == true) {
            views.add({
              "view": View.questions,
              "reference": views[level]["reference"]
                  .doc(query.docs[i].id)
                  .collection("questions")
            });
          }

          /// Otherwise, add next level [View]
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
      else
        return null;
    }
    
  }
  return views;
}

Future<List<Map<String, dynamic>>> getView(
    List<String> hierarchy, int level, List<Map> views, View view) async {
  DocumentReference docReference =
      views[level]["reference"].doc(hierarchy[level + 1]);

  /// Get document snapshot to see if the doc exists
  dynamic snapshot = await docReference.get(GetOptions(source: Source.cache));

  if (snapshot.exists) {
    views.add({"view": view, "reference": docReference});
    return views;
  }

  return null;
}
