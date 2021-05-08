import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzywizzy/services/router.dart';
import 'package:quizzywizzy/services/routing_constants.dart';
import 'package:quizzywizzy/views/loading.dart';
import 'package:quizzywizzy/widgets/body_template.dart';

enum Sort { ratingHigh, ratingLow }

class StudySetView extends StatefulWidget {
  final CollectionReference collection;

  final AppRouterDelegate delegate = Get.find<AppRouterDelegate>();

  StudySetView({@required this.collection});

  @override
  _StudySetViewState createState() => _StudySetViewState();
}

class _StudySetViewState extends State<StudySetView> {
  Stream<QuerySnapshot> snapshots;
  Sort selectedSort;
  List questions;

  void sort() {
    switch (selectedSort) {
      case Sort.ratingHigh:
        questions.sort((a, b) => b["rating"].compareTo(a["rating"]));
        break;
      case Sort.ratingLow:
        questions.sort((a, b) => a["rating"].compareTo(b["rating"]));
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    snapshots = widget.collection.snapshots();
  }

  Widget build(BuildContext context) {
    /// Return list
    return BodyTemplate(
        child: Stack(fit: StackFit.expand, children: [
          /// StreamBuilder that runs every time the question list is changed
      StreamBuilder<QuerySnapshot>(
          stream: snapshots,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingView();
            }

            questions = [];

            /// Compile all questions from docs into one [List]
            snapshot.data.docs.forEach((DocumentSnapshot document) {
              document.data()["questions"].forEach((question) {
                questions.add(question);
              });
            });

            /// Maintain the current sort, so sort the new list of questions
            sort();

            /// Return list
            /// 
            /// Is custom in case ever needs reordering back or other features
            return new ListView.custom(
              childrenDelegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return new Card(
                        margin: const EdgeInsets.all(10.0),
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Material(
                            color: Colors.blue,
                            child: InkWell(
                                splashColor: Colors.red,
                                hoverColor: Colors.blue[600],
                                onTap: () => widget.delegate.pushTemp(["questions", "1" /*questions[index]["id"]*/]),
                                child: Container(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      questions[index]["name"],
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )))));
                  },
                  childCount: questions.length,
                  ),
            );
          }),
      Positioned(
        bottom: 20,
        right: 20,
        child: FloatingActionButton(
          onPressed: () => widget.delegate.pushPseudo(PseudoPage.addQuestion),
          tooltip: 'Add Question',
          child: Icon(Icons.add),
        ),
      ),
      Positioned(
          bottom: 20,
          left: 20,
          child: PopupMenuButton<Sort>(
              icon: Icon(Icons.sort),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<Sort>>[
                    const PopupMenuItem<Sort>(
                      value: Sort.ratingHigh,
                      child: Text('Rating High to Low'),
                    ),
                    const PopupMenuItem<Sort>(
                      value: Sort.ratingLow,
                      child: Text('Rating Low to High'),
                    )
                  ],
              onSelected: (Sort selected) {
                /// Set the state to rebuild the list with the new sort
                setState(() {
                  selectedSort = selected;
                  sort();
                });
              }))
    ]));
  }
}