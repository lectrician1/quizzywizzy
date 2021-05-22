import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizzywizzy/widgets/body_template.dart';

class SingleQuestionView extends StatelessWidget {
  final String id;
  
  SingleQuestionView({@required this.id});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .doc("/questions/$id")
                .get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text("Something went wrong");
              }

              /// Snapshot retreived so render
              if (snapshot.connectionState == ConnectionState.done) {
                print(snapshot.data.metadata.isFromCache);
                //print(snapshot.data.data()["answers"][0]["answer"]);
                return Column(
                  children: [
                    SizedBox(height: 20),
                    Text((snapshot.data.data() as Map)["name"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40,
                        )),
                    SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: 4,
                      itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: ElevatedButton(
                              onPressed: () {},
                              child: Text((snapshot.data.data() as Map)["answers"][index]
                                  ["answer"]))),
                    ),
                  ],
                );
              }
              return Container();
            }));
  }
}
