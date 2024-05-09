import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Piyush_Assignment extends StatefulWidget {
  const Piyush_Assignment({super.key});

  @override
  State<Piyush_Assignment> createState() => _Piyush_AssignmentState();
}

class _Piyush_AssignmentState extends State<Piyush_Assignment> {

  TextEditingController courseController = TextEditingController();
  String dropdownvalue = list.first;
  static const List<String> list = <String>['Class 11', 'Class 12', 'CA Foundation'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 20,),
              DropdownButton<String>(
                isExpanded: true,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.black),
                underline: Container(
                  height: 2,
                  color: Colors.orangeAccent,
                ),
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    dropdownvalue = value!;
                    courseController.text = value;
                  });
                },
                items: list.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                value: dropdownvalue,
              ),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
}
