import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzywizzy/services/router.dart';
import 'package:quizzywizzy/views/widgets/navigation_bar.dart';
import 'package:quizzywizzy/views/widgets/selection_cell.dart';
import 'package:quizzywizzy/constants.dart' as Constants;
import 'package:cloud_firestore/cloud_firestore.dart';

class Questions extends StatelessWidget {
  final List<String> appHierarchy;
  final QuerySnapshot query;
  final AppRouterDelegate delegate = Get.find<AppRouterDelegate>();
  Questions({@required this.appHierarchy, @required this.query});


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
                    padding: const EdgeInsets.all(8),
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
                  )),
            ),
          ),
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        tooltip: 'Add Question',
        child: const Icon(Icons.add),
      ),
    );
  }
}
