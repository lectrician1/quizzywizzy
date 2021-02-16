import 'package:flutter/material.dart';

class NavigationBar extends StatelessWidget {
  final Widget _body;
  final String _title;
  NavigationBar({String title, Widget body}) : 
  _body = body,
  _title = title;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            title: Center(child: Text(_title)),
            floating: true,
          ),
        ];
      },
      body: _body,
    );
  }
}