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
        fit: StackFit.expand,
        children: [
          ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: 100,
            itemBuilder: (context, index) {
              return Text("Hi$index");
            },
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {},
              tooltip: 'Add Question',
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
