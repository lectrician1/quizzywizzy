import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Router
import 'package:quizzywizzy/services/router.dart';

/// Handy functions
import 'package:quizzywizzy/functions.dart';

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
          child: Text("Select a $level",
              style: TextStyle(
                fontSize: 40,
              )),
        )),
        SingleChildScrollView(
          child: Wrap(
            runSpacing: 10,
            spacing: 10,
            alignment: WrapAlignment.center,
            children: docs.map((fields) =>
              SelectionCell(
                  text: fields["name"],
                  icon: Icons.ac_unit,
                  onTap: () {
                    delegate.push(fields["url"]);
                  })
              )
              .toList()
              .cast<Widget>(),
          ),
        ),
      ],
    );
  }
}
