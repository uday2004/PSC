import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChangeFees extends StatefulWidget {
  const ChangeFees({super.key});

  @override
  State<ChangeFees> createState() => _ChangeFeesState();
}

class _ChangeFeesState extends State<ChangeFees> {

  TextEditingController subjectController = TextEditingController();
  TextEditingController classController = TextEditingController();

  String dropdownValue = list.first;
  String dropdownValueSubject = listSubject.first;

  static const List<String> list = <String>['Class 11', 'Class 12', 'CA Foundation'];
  static const List<String> listSubject = <String>['Economics', 'Mathematics'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text('Fees'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text('Select course', style: TextStyle(fontSize: 20),),
            const SizedBox(height: 20,),
            DropdownButton<String>(
              isExpanded: true,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              underline: Container(
                height: 2,
                color: Colors.orangeAccent,
              ),
              onChanged: (String? value) {
                setState(() {
                  dropdownValue = value!;
                  classController.text = value;
                });
              },
              items: list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              value: dropdownValue,
            ),
            if (classController.text == 'Class 12' || classController.text =='Class 11') ...[
              DropdownButton<String>(
                isExpanded: true,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                underline: Container(
                  height: 2,
                  color: Colors.orangeAccent,
                ),
                onChanged: (String? value) {
                  setState(() {
                    dropdownValueSubject = value!;
                    subjectController.text = value;
                  });
                },
                items: listSubject.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                value: dropdownValueSubject,
              ),
            ],
            const SizedBox(height: 10,),
            const Divider(),
            const Text('Fees', style: TextStyle(fontSize: 20),),
            const SizedBox(height: 20,),
            TextField(
              decoration: InputDecoration(
                label: Text('Fees for ${classController.text}')
              ),
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
                onPressed: (){

                },
                child: const Text('Save',style: TextStyle(color: Colors.orangeAccent),),
            ),
            const SizedBox(height: 20,),
            const Divider(),
            const SizedBox(height: 20,),
            const Text('Current fees', style: TextStyle(fontSize: 20),),
            const SizedBox(height: 20,),
            StreamBuilder(
                stream: FirebaseFirestore.instance.collection('Fees').snapshots(),
                builder: (context, snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return const Center(child: CircularProgressIndicator());
                  }if(snapshot.hasError){
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  return Container();
                }
            )
          ],
        ),
      ),
    );
  }
}
