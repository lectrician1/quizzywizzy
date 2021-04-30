import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Router
import 'package:quizzywizzy/services/router.dart';

/// Widgets
import 'package:quizzywizzy/widgets/body_template.dart';
import 'package:quizzywizzy/widgets/selection_cell.dart';

class AppHomeView extends StatelessWidget {
  final AppRouterDelegate delegate = Get.find<AppRouterDelegate>();
  final CollectionReference collection;

  AppHomeView({@required this.collection});

  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: collection.get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return BodyTemplate(
              child: ListView(
            shrinkWrap: true,
            children: [
              Center(
                  child: Container(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text(collection.id.capitalize,
                    style: TextStyle(
                      fontSize: 40,
                    )),
              )),
              SingleChildScrollView(
                child: Wrap(
                  runSpacing: 20,
                  spacing: 20,
                  alignment: WrapAlignment.center,
                  children: snapshot.data.docs
                      .map((docSnapshot) {
                        Map doc = docSnapshot.data();
                        return SelectionCell(
                            icon: Icons.ac_unit,
                            text: doc["name"],
                            type: doc.containsKey("questions")
                                ? (doc["questions"] ? 0 : 1)
                                : 2,
                            onTap: () {
                              delegate.push(doc["url"]);
                            });
                      })
                      .toList()
                      .cast<Widget>(),
                ),
              ),
            ],
          ));
        });
  }
}
