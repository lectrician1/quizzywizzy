/// Flutter code sample for Form
// This example shows a [Form] with one [TextFormField] to enter an email
// address and an [ElevatedButton] to submit the form. A [GlobalKey] is used here
// to identify the [Form] and validate input.
//
// ![](https://flutter.github.io/assets-for-api-docs/assets/widgets/form.png)

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (context) => AnswersModel(),
        child: MyApp(),
      ),
    );

/// This is the main application widget.
class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: Scrollbar(child: MyStatefulWidget()),
      ),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var answersModal = context.watch<AnswersModel>();

    return Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 100, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Question title',
                ),
                validator: (String value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
                textAlign: TextAlign.center,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Question description',
                ),
                validator: (String value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              Answers(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                    child: const Icon(Icons.add_rounded),
                    onPressed: () {
                      answersModal.add();
                    }),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    if (_formKey.currentState.validate()) {
                      // Process data.
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ));
  }
}

class AnswersModel extends ChangeNotifier {
  List<Widget> _answers = [Answer()];

  List<Widget> get answers => _answers;

  void add() {
    _answers.add(Answer());
    notifyListeners();
  }

  void remove(Key key) {
    _answers.removeWhere((answer) => answer.key == key);
    notifyListeners();
  }
}

class Answers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var answersModel = context.watch<AnswersModel>();

    return ListView.builder(
        shrinkWrap: true,
        itemCount: answersModel.answers.length,
        itemBuilder: (context, index) => answersModel.answers[index]);
  }
}

class Answer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Row(
      children: <Widget>[
      Expanded(
          child: TextFormField(
        textAlign: TextAlign.center,
        maxLines: null,
        decoration: InputDecoration(
          hintText: 'Answer',
        ),
        validator: (String value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
      ),
      ),
      RemoveAnswer(key: key)
    ]);
  }
}

class RemoveAnswer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var answersModel = context.watch<AnswersModel>();

    if (answersModel.answers.length > 1) {
      return ElevatedButton(
        child: Icon(Icons.remove_rounded),
        onPressed: () => answersModel.remove(key),
      );
    }

    return Container(width: 0.0, height: 0.0);
  }
}
