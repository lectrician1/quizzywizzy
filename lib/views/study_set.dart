import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzywizzy/services/router.dart';
import 'package:quizzywizzy/widgets/navigation_bar.dart';
import 'package:quizzywizzy/constants.dart';

class StudySetView extends StatelessWidget {
  final List<String> appHierarchy;
  final AppRouterDelegate delegate = Get.find<AppRouterDelegate>();
  StudySetView({@required this.appHierarchy});

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
                    children: [Text("hi")],
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
