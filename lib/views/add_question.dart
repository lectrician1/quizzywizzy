/// Flutter code sample for Form
// This example shows a [Form] with one [TextFormField] to enter an email
// address and an [ElevatedButton] to submit the form. A [GlobalKey] is used here
// to identify the [Form] and validate input.
//
// ![](https://flutter.github.io/assets-for-api-docs/assets/widgets/form.png)

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// This is the stateful widget that the main application instantiates.
class AddQuestionView extends StatelessWidget {
  

  void _submit (Map question) {
    CollectionReference questions = FirebaseFirestore.instance.collection('questions');

    questions.add(question)
      .then((value) => print("User Added"))
      .catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    var question = {
      "name": '',
      "answers": [],
    };

    return Form(
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
                    onFieldSubmitted: (String field) => question['name'] = field,
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
                        onFieldSubmitted: (String field) => question['answers'].add(field),
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
                          // Process data.
                          _submit();
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
