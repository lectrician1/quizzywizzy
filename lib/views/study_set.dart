import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzywizzy/services/router.dart';
import 'package:quizzywizzy/services/routing_constants.dart';
import 'package:quizzywizzy/widgets/body_template.dart';

/// Import the firebase_core and cloud_firestore plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class StudySetView extends StatelessWidget {
  final List<String> appHierarchy;
  final AppRouterDelegate delegate = Get.find<AppRouterDelegate>();
  StudySetView({@required this.appHierarchy});

  /*
  FirebaseFirestore.instance
    .collection('questions')
    .where('age', isGreaterThan: 20)
    .get()
    .then(...);
  */

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
              onPressed: () => delegate.pushPseudo(PseudoPage.addQuestion),
              tooltip: 'Add Question',
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
