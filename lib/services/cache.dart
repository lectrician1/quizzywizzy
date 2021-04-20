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
    print(hierarchy);
    Map collection = _cache[hierarchy[0]];
    print(collection["documents"]);

    for (int i = 0; i <= hierarchy.length; i++) {
      if (collection["documents"].isEmpty) {
        print("ok");
        print(collection["reference"]);
        QuerySnapshot query = await collection["reference"].get();

        if (collection["view"] == "questions") {
          /// Declare documents as [List] (required)
          collection["documents"] = [];

          query.docs.forEach((docSnap) {
            collection["documents"].add(docSnap.data());
          });
          i = hierarchy.length + 1;
        } else {
          /// Declare documents as [Map] (required)
          collection["documents"] = {};

          query.docs.forEach((docSnap) {
            Map fields = docSnap.data();

            String view = "level";
            CollectionReference collectionReference;

            if (fields["questions"]) {
              view = "questions";
              collectionReference = docSnap.reference.collection("questions");
            } else {
              view = collectionNames[i + 1];
              collectionReference =
                  docSnap.reference.collection(collectionNames[i + 1]);
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

      if (collection["documents"][hierarchy[i + 1]] == null)
        return true;
      else
        collection = collection["documents"][hierarchy[i + 1]]["collection"];
    }

    return false;
  }

  List<Map> getLevels(List hierarchy) {
    /// Docs in hierarchy order
    List<Map> levels;

    Map collection = _cache[hierarchy[0]];

    for (int i = 1; i < hierarchy.length; i++) {
      levels.add(collection);

      collection = collection["documents"][hierarchy[i]]["collection"];
    }

    return levels;
  }
}
