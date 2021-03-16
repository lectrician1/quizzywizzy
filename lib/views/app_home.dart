import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzywizzy/services/router.dart';
import 'package:quizzywizzy/views/widgets/navigation_bar.dart';
import 'package:quizzywizzy/views/widgets/resizer.dart';
import 'package:quizzywizzy/views/widgets/selection_cell.dart';
import 'package:quizzywizzy/constants.dart' as Constants;

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
    return Scaffold(
      body: NavigationBar(
        title: Constants.title,
        body: SafeArea(
          child: Scrollbar(
            child: Align(
              alignment: Alignment.topCenter,
              child: WidthResizer(
                  widthFactor: 0.75,
                  constraintWidth: 800,
                  builder: _getHomeContent),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getHomeContent(BuildContext context, BoxConstraints constraints) {
    return ListView(
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
                    width: 200,
                    height: 200,
                    text: docData[Constants.docName],
                    icon: Icons.ac_unit,
                    onTap: () {
                      delegate.push(docData[Constants.docUrlName]);
                      /*Navigator.of(context)
                                .pushReplacementNamed(
                                    Constants.getCourseRoute(doc.data()["name"]));*/
                    }))
                .toList(),
          ),
        ),
      ],
    );
  }
}
