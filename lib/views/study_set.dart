import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzywizzy/services/router.dart';
import 'package:quizzywizzy/widgets/body_template.dart';

class StudySetView extends StatelessWidget {
  final List<String> appHierarchy;
  final AppRouterDelegate delegate = Get.find<AppRouterDelegate>();
  StudySetView({@required this.appHierarchy});

  Widget build(BuildContext context) {
    return BodyTemplate(
      child: Stack(
        children: [
          FloatingActionButton(
            onPressed: () {},
            tooltip: 'Add Question',
            child: Icon(Icons.add),
          ),
          ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            children: [Text("hi")],
          ),
        ],
      ),
    );
  }
}
