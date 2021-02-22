import 'package:flutter/material.dart';
import 'package:quizzywizzy/views/widgets/navigation_bar.dart';
import 'package:quizzywizzy/views/widgets/selection_cell.dart';
import 'package:quizzywizzy/constants.dart' as Constants;

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NavigationBar(
        backButtonRoute: "",
        backButtonType: 2,
        title: Constants.title,
        body: SafeArea(
          child: Scrollbar(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: BoxConstraints(maxWidth: 600),
                child: ListView(
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
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 150,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0,
                        //maxCrossAxisCount: 5,
                      ),
                      children: List.generate(
                          40,
                          (index) => SelectionCell(
                              text: "hi",
                              icon: Icons.ac_unit,
                              onTap: () {
                                Navigator.of(context).pushReplacementNamed(Constants.getCourseRoute(index));
                              })),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}