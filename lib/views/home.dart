import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Text("QuizzyWizzy"),
              floating: true,
            ),
          ];
        },
        body: SafeArea(
          child: Scrollbar(
            child: Center(
                child: Container(
              constraints: BoxConstraints(maxWidth: 600),
              child: GridView(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.0,
                  //maxCrossAxisCount: 5,
                ),
                children: List.generate(20, (index) => Course(text: "hi")),
              ),
            )),
          ),
        ),
      ),
    );
  }
}

class Course extends StatelessWidget {
  String _text;
  Course({String text}) {
    this._text = text;
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, "/");
      },
      child: Container(
        color: Colors.amber,
        child: Text(_text),
      ),
    );
  }
}
