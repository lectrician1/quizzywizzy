import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// This is the stateful widget that the main application instantiates.
class AddQuestionView extends StatefulWidget {
  final CollectionReference collection;
  AddQuestionView(this.collection);

  @override
  _AddQuestionViewState createState() => _AddQuestionViewState();
}

class _AddQuestionViewState extends State<AddQuestionView> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  var question = {
    "name": '',
    "answers": [],
  };

  void _submit() async {
    CollectionReference questions =
        FirebaseFirestore.instance.collection('questions');

    String questionID;
    await questions
        .add(question)
        .then((value) {
          print("Question Added");
          questionID = value.id;
        })
        .catchError((error) => print("Failed to add question: $error"));

    widget.collection
        .doc("5hHxF5dpGE8flf375FCY")
        .update({
          "questions": FieldValue.arrayUnion([{"name": question["name"], "rating": 1, "id": questionID}])
        })
        .then((value) => print("Question Added to List"))
        .catchError((error) => print("Failed to add question to list: $error"));
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
                        onSaved: (value) => question['name'] = value,
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
                            onSaved: (value) => (question['answers'] as List)
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
