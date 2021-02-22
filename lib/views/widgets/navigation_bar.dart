import 'package:flutter/material.dart';

class NavigationBar extends StatelessWidget {
  final Widget _body;
  final String _title;
  final String _backButtonRoute;
  final int _backButtonType;
  NavigationBar(
      {@required String title,
      @required String backButtonRoute,
      @required Widget body,
      int backButtonType = 0})
      : _body = body,
        _backButtonRoute = backButtonRoute,
        _title = title,
        _backButtonType = backButtonType;

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
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _getBackButton(context, _backButtonType),
                    ]),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      OutlinedButton(
                          onPressed: () {},
                          child: Text("Sign In"),
                          style: ButtonStyle(
                              overlayColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white))),
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

  Widget _getBackButton(BuildContext context, int backButtonType) {
    switch (backButtonType) {
      case 1:
        return Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                })
            : Container();
      case 2:
        return Container();
      default:
        return IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(_backButtonRoute);
            });
    }
  }
}
