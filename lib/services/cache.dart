import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizzywizzy/services/routing_constants.dart';

Future<DocumentReference> getFirestoreDoc(List hierarchy) async {
  switch (hierarchy[0]) {
    case "courses":

      /// Get the starting collection
      CollectionReference collection =
          FirebaseFirestore.instance.collection("courses");

      /// Level iterator
      int nextLevel = 1;

      /// Check each given level of the hierarchy to see if it has a valid page (Firestore document)
      while (nextLevel <= hierarchy.length) {
        /// Get the documents in the collection
        QuerySnapshot query = await collection.get();

        /// If document has been found for this level
        bool foundDoc = false;

        /// Document iterator
        int i = 0;

        /// Check each document in the level if it has the url of the next level.
        /// That means the level is a valid page.
        while (i < query.docs.length) {
          /// If the doc has been found
          if (hierarchy[nextLevel] == query.docs[i].data()["url"]) {
            foundDoc = true;

            /// If it is not the last level, set collection for next level.
            ///
            /// We do not want to get the collection for the last level because
            /// [nextLevel] needs to always be less than [collectionNames.length].
            if (nextLevel + 1 < hierarchy.length) {
              collection = collection
                  .doc(query.docs[i].id)
                  .collection(collectionNames[nextLevel]);
            } else
              return collection.doc(query.docs[i].id);

            /// Stop checking documents
            break;
          }

          /// Advance to the next document
          i++;
        }

        if (foundDoc)

          /// Advance to the next level
          nextLevel++;
        else

          /// If a document was never found in the collection, return false.
          return null;
      }

      /// Return true if docs have been found for all levels
      return true;
    case "questions":

      /// Check if document id is provided
      if (hierarchy[1] != null) {
        /// Get document snapshot to see if the doc exists
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .doc("questions/" + hierarchy[1])
            .get();

        /// Return true if question document exists
        if (snapshot.exists) return true;
      }
  }

  /// No true for a page existing before, so return false.
  return false;
}
