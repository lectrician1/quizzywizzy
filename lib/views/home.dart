import 'package:flutter/material.dart';
import 'package:quizzywizzy/views/widgets/navigation_bar.dart';
import 'package:quizzywizzy/views/widgets/selection_cell.dart';
import 'package:quizzywizzy/constants.dart' as Constants;
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeView extends StatelessWidget {
  final List<String> hierarchy;
  HomeView(this.hierarchy);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NavigationBar(
        backButtonRoute: Constants.getRouteBackButton(hierarchy),
        backButtonType: 2,
        title: Constants.title,
        body: SafeArea(
          child: Scrollbar(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: BoxConstraints(maxWidth: 600),
                child: FutureBuilder<QuerySnapshot>(
                    future: getCollection(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        return ListView(
                          children: [
                            Center(
                                child: Container(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text("Select a course",
                                  style: TextStyle(
                                    fontSize: 40,
                                  )),
                            )),
                            GridView(
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 150,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1.0,
                                //maxCrossAxisCount: 5,
                              ),
                              children: snapshot.data.docs.map((doc) => SelectionCell(
                                      text: doc.data()["name"],
                                      icon: Icons.ac_unit,
                                      onTap: () {
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                                Constants.getCourseRoute(doc.data()["name"]));
                                      })).toList(),
                            ),
                          ],
                        );
                      }
                      return Center(child: CircularProgressIndicator());
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Future<QuerySnapshot> getCollection() async {
    CollectionReference reference = FirebaseFirestore.instance.collection(Constants.mainHierarchy[0]);
    for (int i=0; i<hierarchy.length-1; i++) {
      QuerySnapshot query = await reference.where("name", isEqualTo: this.hierarchy[i]).limit(1).get();
      if (query.docs.length == 0) return null;
      reference = query.docs[0].reference.collection(Constants.mainHierarchy[i+1]);
    }
    return await reference.get();
  }
}
