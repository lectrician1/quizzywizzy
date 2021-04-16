/*
  Map<String, dynamic> cache = {
    "courses" : Map<String, dynamic> {
      "reference" : CollectionReference
      "documents" : [
        {
          "fields" : {
            "name" : "AP Calculus"
          }
          "collections" : List<Map> = [
            {
              "reference" : CollectionReference
              "documents" : [ 
                {
                  "fields" : {
                    name = "Series"
                  }
                }
              ]
            }
          ]
        }
        }
      ]
    }
    "questions" : ...
  };
*/
import 'package:cloud_firestore/cloud_firestore.dart';

class Cache {
  Map<String, dynamic> _cache;

  Cache() {
    _cache = {
      "courses": {"reference": FirebaseFirestore.instance.collection("courses")}
    };
  }

  Map<String, dynamic> getDocs(String path) {
    
  }
}
