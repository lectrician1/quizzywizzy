/*
  Map<String, dynamic> cache = {
    "courses" : {
      "reference" : CollectionReference
      "documents" : {
        "ap-calculus" : {
          "view" : "questions",
          "fields" : {
            "name" : "AP Calculus"
          },
          "collection" : {
            "reference" : CollectionReference
            "questions" : false
            "documents" : [ 
              {
                "fields" : {
                  name = "Series"
                }
              }
            ]
          }
        }
      }
    }
    "questions" : ...
  };
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizzywizzy/services/routing_constants.dart';

class Cache {
  Map<String, dynamic> _cache;

  Cache() {
    _cache = {
      "courses": {
        "reference": FirebaseFirestore.instance.collection("courses"),
        "view": "courses",
        "documents": {}
      }
    };
  }

  Future<bool> storeDocs(List hierarchy) async {
    Map collection = _cache[hierarchy[0]];

    int nextLevel = 1;

    while (nextLevel <= hierarchy.length) {
      if (collection["documents"].isEmpty) {
        QuerySnapshot query = await collection["reference"].get();

        if (collection["view"] == "questions") {
          /// Declare documents as [List] (required)
          collection["documents"] = [];

          query.docs.forEach((docSnap) {
            collection["documents"].add(docSnap.data());
          });
          break;
        } else {
          /// Declare documents as [Map] (required)
          collection["documents"] = {};

          query.docs.forEach((docSnap) {
            Map fields = docSnap.data();

            String view = "level";
            CollectionReference collectionReference;

            if (fields["questions"] != null && fields["questions"]) {
              view = "questions";
              collectionReference = docSnap.reference.collection("questions");
            } else {
              view = collectionNames[nextLevel];
              collectionReference =
                  docSnap.reference.collection(collectionNames[nextLevel]);
            }

            collection["documents"][fields["url"]] = {
              "fields": fields,
              "collection": {
                "reference": collectionReference,
                "view": view,
                "documents": {}
              }
            };
          });
        }
      }
      if (nextLevel != hierarchy.length) {
        if (collection["documents"][hierarchy[nextLevel]] == null)
          return true;
        else
          collection =
              collection["documents"][hierarchy[nextLevel]]["collection"];
      } else
        break;
      nextLevel++;
    }

    return false;
  }

  List<Map> getLevels(List hierarchy) {
    /// Docs in hierarchy order
    List<Map> levels = [];

    print(_cache);
    print(hierarchy);

    Map collection = _cache[hierarchy[0]];
    levels.add(collection);

    for (int i = 1; i < hierarchy.length; i++) {
      levels.add(collection);

      collection = collection["documents"][hierarchy[i]]["collection"];
    }

    return levels;
  }
}
