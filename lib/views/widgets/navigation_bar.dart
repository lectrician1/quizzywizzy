import 'package:flutter/material.dart';

class NavigationBar extends StatelessWidget {
  final Widget _body;
  final String _title;
  final String _backButtonRoute;
  final bool _backButtonShouldPop;
  NavigationBar({@required String title, @required String backButtonRoute, @required Widget body, bool backButtonShouldPop = false})
      : _body = body,
        _backButtonRoute = backButtonRoute,
        _title = title,
        _backButtonShouldPop = backButtonShouldPop;

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
                      (_backButtonShouldPop & Navigator.canPop(context)) ? IconButton(onPressed: () {
                        Navigator.pop(context);
                      }, icon: Icon(Icons.arrow_back)) :
                      (_backButtonRoute != "" ? IconButton(onPressed: () {
                        Navigator.of(context).pushReplacementNamed(_backButtonRoute);
                      }, icon: Icon(Icons.arrow_back)) : Container())
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
