import 'package:quizzywizzy/constants.dart' as Constants;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'widgets/navigation_bar.dart';

class Questions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NavigationBar(title: Constants.title, backButtonRoute: "", body: Container()),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        tooltip: 'Add Question',
        child: const Icon(Icons.add),
      ),
    );
  }
}
