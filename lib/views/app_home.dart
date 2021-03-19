import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzywizzy/services/router.dart';
import 'package:quizzywizzy/widgets/body_template.dart';
import 'package:quizzywizzy/widgets/selection_cell.dart';
import 'package:quizzywizzy/constants.dart';

class AppHomeView extends StatelessWidget {
  final List<String> appHierarchy;
  final List<Map<String, dynamic>> queryData;
  final List<String> viewTitles = [
    "Select a Course",
    "Select a Unit",
    "Select a Topic",
    "Select a Subtopic"
  ];
  final AppRouterDelegate delegate = Get.find<AppRouterDelegate>();
  AppHomeView({@required this.appHierarchy, @required this.queryData});
  Widget build(BuildContext context) {
    return BodyTemplate(child: _getHomeContent(context));
  }

  Widget _getHomeContent(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Center(
            child: Container(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text(viewTitles[appHierarchy.length],
              style: TextStyle(
                fontSize: 40,
              )),
        )),
        SingleChildScrollView(
          child: Wrap(
            runSpacing: 10,
            spacing: 10,
            alignment: WrapAlignment.center,
            children: queryData
                .map((docData) => SelectionCell(
                    text: docData[Constants.docName],
                    icon: Icons.ac_unit,
                    onTap: () {
                      delegate.push(docData[Constants.docUrlName]);
                      /*Navigator.of(context)
                                .pushReplacementNamed(
                                    Constants.getCourseRoute(doc.data()["name"]));*/
                    }))
                .toList().cast<Widget>(),
          ),
        ),
      ],
    );
  }
}
