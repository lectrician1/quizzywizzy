import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Router
import 'package:quizzywizzy/services/router.dart';

/// Widgets
import 'package:quizzywizzy/widgets/body_template.dart';
import 'package:quizzywizzy/widgets/selection_cell.dart';
import 'package:transparent_image/transparent_image.dart';

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
            children: docs
                .map((doc) {
                  return SelectionCell(
                    image: doc.containsKey("img") ? CachedNetworkImage(imageUrl: doc["img"]) : Image.memory(kTransparentImage),
                    text: doc["name"],
                    type: doc.containsKey("questions") ? (doc["questions"] ? 0 : 1) : 2,
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






