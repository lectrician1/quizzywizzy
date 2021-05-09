import 'package:flutter/material.dart';
import 'package:quizzywizzy/widgets/body_template.dart';

class AddQuestionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   return Dialog(child: MyCustomForm());
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'question title',
            ),
          ),
        ),
          Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'greyout static',
            ),
          ),
        ),
      ],
    );
  }
}

class DynamicallyCheckbox extends StatefulWidget {
  @override
  DynamicallyCheckboxState createState() => new DynamicallyCheckboxState();
}

class DynamicallyCheckboxState extends State {

  Map<String, bool> List = {
    'A' : false,
    'B' : false,
    'C' : false,
  };

  var holder_1 = [];

  getItems(){
    List.forEach((key, value) {
      if(value == true)
      {
        holder_1.add(key);
      }
    });

    print(holder_1);
    holder_1.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column (children: <Widget>[
      
      Expanded(
        child :
        ListView(
          children: List.keys.map((String key) {
            return CheckboxListTile(
              title: Text(key),
              value: List[key],
              activeColor: Colors.green[400],
              checkColor: Colors.white,
              onChanged: (bool value) {
                setState(() {
                  List[key] = value;
                });
              },
            );
          }).toList(),
        ),
      ),
    
        ElevatedButton(
          child: Text(" Enter"),
          onPressed: getItems,
          style: ElevatedButton.styleFrom(
           primary: Colors.green,
           padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
           textStyle: TextStyle(
             color:Colors.black
           ),
          )
      ),
    
    ]);
    
  }
}
