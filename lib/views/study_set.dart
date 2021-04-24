import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzywizzy/services/router.dart';
import 'package:quizzywizzy/services/routing_constants.dart';
import 'package:quizzywizzy/widgets/body_template.dart';



class StudySetView extends StatelessWidget {
  final List docs;

  final AppRouterDelegate delegate = Get.find<AppRouterDelegate>();

  StudySetView({@required this.docs});

  /*
  FirebaseFirestore.instance
    .collection('questions')
    .where('age', isGreaterThan: 20)
    .get()
    .then(...);
  */

  Widget build(BuildContext context) {
    return BodyTemplate(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: docs[0]["questions"].length,
            itemBuilder: (context, index) {
              return Text(docs[0]["questions"][index]["name"]);
            },
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => delegate.pushPseudo(PseudoPage.addQuestion),
              tooltip: 'Add Question',
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

/* 
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyListView(),
    );
  }
}

class MyListView extends StatefulWidget {
  @override
  _MyListViewState createState() => _MyListViewState();
}

class _MyListViewState extends State<MyListView> {
  List<Map> items = [
    { 
      "rating": 5, 
      "name": "Which of the following observations is best explained by water’s high surface tension?"
    },
    {
      "rating": 3, 
      "name": "ok"
    },
  ];

  void _reverse() {
    setState(() {
      items = items.reversed.toList();
    });
  }
  
  void _sort() {
    setState(() {
      items.sort((a, b) => a["rating"].compareTo(b["rating"]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.custom(
          childrenDelegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return KeepAlive(
                data: items[index]["name"],
                key: ValueKey<int>(index),
              );
            },
            childCount: items.length,
            findChildIndexCallback: (Key key) {
              final ValueKey valueKey = key as ValueKey;
              final int data = valueKey.value;
              return data;
            }
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () => _reverse(),
              child: Text('Reverse items'),
            ),
            TextButton(
              onPressed: () => _sort(),
              child: Text('Sort rating'),
            ),
          ],
        ),
      ),
    );
  }
}

class KeepAlive extends StatefulWidget {
  const KeepAlive({
    required Key key,
    required this.data,
  }) : super(key: key);

  final String data;

  @override
  _KeepAliveState createState() => _KeepAliveState();
}

class _KeepAliveState extends State<KeepAlive> with AutomaticKeepAliveClientMixin{
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Text(widget.data);
  }
}
*/