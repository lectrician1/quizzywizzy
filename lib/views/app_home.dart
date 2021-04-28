import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Router
import 'package:quizzywizzy/services/router.dart';

/// Widgets
import 'package:quizzywizzy/widgets/body_template.dart';
import 'package:quizzywizzy/widgets/selection_cell.dart';

class AppHomeView extends StatelessWidget {
  final String level;
  final List docs;
  final AppRouterDelegate delegate = Get.find<AppRouterDelegate>();
  AppHomeView({@required this.level, @required this.docs});
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
          child: Text(level.capitalize,
              style: TextStyle(
                fontSize: 40,
              )),
        )),
        SingleChildScrollView(
          child: Wrap(
            runSpacing: 20,
            spacing: 20,
            alignment: WrapAlignment.center,
            children: queryData
                .map((doc) {
                  return SelectionCell(
                    icon: Icons.ac_unit,
                    text: doc["name"],
                    type: doc.containsKey("questions") ? (doc["questions"] ? 1 : 0) : 2,
                    onTap: () {
                      delegate.push(doc["url"]);
                    });})
                .toList()
                .cast<Widget>(),
          ),
        ),
      ],
    );
  }
}






