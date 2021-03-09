import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzywizzy/services/router.dart';
import 'package:quizzywizzy/views/widgets/navigation_bar.dart';
import 'package:quizzywizzy/views/widgets/selection_cell.dart';
import 'package:quizzywizzy/constants.dart' as Constants;
import 'package:cloud_firestore/cloud_firestore.dart';

class AppHomeView extends StatelessWidget {
  final List<String> appHierarchy;
  final QuerySnapshot query;
  final AppRouterDelegate delegate = Get.find<AppRouterDelegate>();
  AppHomeView({@required this.appHierarchy, @required this.query});

  Widget build(BuildContext context) {
    return Scaffold(
      body: NavigationBar(
        title: Constants.title,
        body: SafeArea(
          child: Scrollbar(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: ListView(
                    children: [
                      Center(
                          child: Container(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text("Select a course",
                            style: TextStyle(
                              fontSize: 40,
                            )),
                      )),
                      GridView(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.0,
                          //maxCrossAxisCount: 5,
                        ),
                        children: query.docs
                            .map((doc) => SelectionCell(
                                text: doc.data()["name"],
                                icon: Icons.ac_unit,
                                onTap: () {
                                  delegate.push(doc.data()["url name"]);
                                  /*Navigator.of(context)
                                            .pushReplacementNamed(
                                                Constants.getCourseRoute(doc.data()["name"]));*/
                                }))
                            .toList(),
                      ),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
