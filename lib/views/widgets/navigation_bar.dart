import 'package:flutter/material.dart';

class NavigationBar extends StatelessWidget {
  final Widget _body;
  final String _title;
  NavigationBar({String title, Widget body})
      : _body = body,
        _title = title;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            title: Container(
              constraints: BoxConstraints(maxWidth: 800),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      IconButton(onPressed: () {
                        Navigator.maybePop(context);
                      }, icon: Icon(Icons.arrow_back))
                    ]),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      ElevatedButton(onPressed: () {}, child: Text("Sign In")),
                    ]),
                  ),
                  Text(_title),
                ],
              ),
            ),
            centerTitle: true,
            floating: true,
          ),
        ];
      },
      body: _body,
    );
  }
}
