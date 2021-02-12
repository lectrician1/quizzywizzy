import 'package:flutter/material.dart';

class RouteNotFoundView extends StatelessWidget {
  final String name;
  const RouteNotFoundView({Key key, this.name}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        title: Text("$name cannot be found"),
        floating: true,
      ),
    ];
      },
      body: Container(),
    ));
  }
}