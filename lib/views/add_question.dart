import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizzywizzy/services/routing_constants.dart';

/// This is the stateful widget that the main application instantiates.
class AddQuestionView extends StatefulWidget {
  final List<String> path;
  AddQuestionView(this.path);

  @override
  _AddQuestionViewState createState() => _AddQuestionViewState();
}

class _AddQuestionViewState extends State<AddQuestionView> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  var questionData = {
    //"author": '',
    "date": Timestamp(0, 0),
    //"question": '',
    "answers": [],
  };

  @override
  void initState() {
    super.initState();
    int j = 0;
    for (int i = 1; i < widget.path.length; i += 2) {
      questionData[collectionNames[j]] = widget.path[i];
      j++;
    }
  }

  void _submit() async {
    FirebaseFirestore.instance
        .collection('questions')
        .add(questionData)
        .then((question) {
      print("Question Added");
    }).catchError((error) => print("Failed to add question: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 100, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                        onSaved: (value) => questionData['name'] = value,
                      )
                    ] +
                    List.filled(
                        4,
                        Row(children: <Widget>[
                          Expanded(
                              child: TextFormField(
                            textAlign: TextAlign.center,
                            maxLines: null,
                            decoration: const InputDecoration(
                              hintText: 'Answer',
                            ),
                            validator: (String value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            onSaved: (value) =>
                                (questionData['answers'] as List)
                                    .add({"answer": value}),
                          ))
                        ])) +
                    [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            // Validate will return true if the form is valid, or false if
                            // the form is invalid.
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();

                              questionData["date"] =
                                  Timestamp.fromDate(DateTime.now());

                              // Process data.
                              _submit();
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
              ),
            )));
  }
}
