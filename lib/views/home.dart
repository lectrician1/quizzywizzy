import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzywizzy/services/router.dart';
import 'package:quizzywizzy/widgets/body_template.dart';

class HomeView extends StatelessWidget {
  final AppRouterDelegate delegate = Get.find<AppRouterDelegate>();
  @override
  Widget build(BuildContext context) {
    return BodyTemplate(
        child: Center(
          child: ElevatedButton(
              onPressed: () {
                delegate.setStack(["app"]);
              },
              child: Text("Launch App")),
        ));
  }
}
