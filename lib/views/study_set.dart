import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzywizzy/services/router.dart';
import 'package:quizzywizzy/services/routing_constants.dart';
import 'package:quizzywizzy/views/add_question.dart';
import 'package:quizzywizzy/views/loading.dart';
import 'package:quizzywizzy/views/single_question.dart';
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
  // List questions;
  List path;

  /*
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
  */

  /// Needed because [widget.collection.snapshots()] can't be called outside of a function
  @override
  void initState() {
    super.initState();

    path = widget.collection.path.split('/');

    Query query = FirebaseFirestore.instance.collection("questions");

    for (int i = 1; i < path.length; i + 2) {
      query = query.where(path[i]);
    }
    snapshots = query.limit(10).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return BodyTemplate(
        child: Stack(fit: StackFit.expand, children: [
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

            // Maintain the current sort, so sort the new list of questions
            //sort();

            // Return list
            //
            // Is custom in case ever needs reordering back or other features
            return ListView.custom(
              childrenDelegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Card(
                      margin: const EdgeInsets.all(10.0),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        tileColor: Colors.blue,
                        title: Container(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              snapshot.data.docs[index]["name"],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                        hoverColor: Colors.blue[600],
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  SingleQuestionView(
                                      reference:
                                          snapshot.data.docs[index].reference));
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            snapshot.data.docs[index].reference
                                .delete()
                                .then((value) => print("Question Removed"))
                                .catchError((error) =>
                                    print("Failed to remove: $error"));
                          },
                        ),
                      ));
                },
                childCount: snapshot.data.docs.length,
              ),
            );
          }),
      /*
              Positioned(
                  bottom: 20,
                  left: 20,
                  child: PopupMenuButton<Sort>(
                      icon: Icon(Icons.sort),
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<Sort>>[
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
                      })) */
      Positioned(
        bottom: 20,
        right: 20,
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => AddQuestionView(path));
          },
          tooltip: 'Add Question',
          child: Icon(Icons.add),
        ),
      )
    ]));
  }
}
