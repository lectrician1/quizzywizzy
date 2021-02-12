import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
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
            child: Align(
                alignment: Alignment.topCenter,
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
                    children: List.generate(
                        40,
                        (index) => SelectionCell(
                            text: "hi",
                            icon: Icons.ac_unit,
                            onTap: () {
                              Navigator.of(context).pushNamed('/courses/$index');
                              /*
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseView(),
                                ),
                              );*/
                            })),
                  ),
                )),
          ),
        ),
      ),
    );
  }
}

class SelectionCell extends StatelessWidget {
  final String _text;
  final Function _onTap;
  final IconData _icon;
  SelectionCell({String text, IconData icon, Function onTap})
      : this._text = text,
        this._icon = icon,
        this._onTap = onTap;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Material(
        color: Colors.amber,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: InkWell(
          splashColor: Colors.blue,
          onTap: _onTap,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: Icon(
                    _icon,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(_text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
