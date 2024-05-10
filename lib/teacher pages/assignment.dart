import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  List<File> pickedFile = [];

  Future<void> uploadFile() async {
    final storage = FirebaseStorage.instance;
    for (var file in pickedFile) {
      final ref = storage.ref().child('Assignments/$courseController/${file.path}');
      await ref.putFile(file);
    }
  }

  Future<void> removeFile(int index) async {
    setState(() {
      pickedFile.removeAt(index);
    });
  }

  Future<void> selectFile() async {
    final results = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (results != null) {
      setState(() {
        pickedFile = results.files.map((file) => File(file.path!)).toList();
      });
    }
  }

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return MeetingOption(
                pickedFile: pickedFile,
                uploadFile: uploadFile,
                removeFile: removeFile,
              );
            },
          );
        },
        child: const Icon(CupertinoIcons.pen),
      ),
    );
  }
}


class MeetingOption extends StatefulWidget {
  final List<File> pickedFile;
  final Function() uploadFile;
  final Function(int) removeFile;

  const MeetingOption({
    required this.pickedFile,
    required this.uploadFile,
    required this.removeFile,
    super.key,
  });

  @override
  State<MeetingOption> createState() => _MeetingOptionState();
}

class _MeetingOptionState extends State<MeetingOption> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(CupertinoIcons.xmark),
        ),
        title: const Text('Edit Assignment'),
      ),
      body: Column(
        children: [
          const Divider(),
          TextButton(
            onPressed: widget.uploadFile,
            child: const Row(
              children: [
                Icon(
                  CupertinoIcons.add,
                  color: Colors.black,
                ),
                SizedBox(width: 25,),
                Text(
                  'Add',
                  style: TextStyle(
                      fontSize: 23,
                      color: Colors.black
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10,),
          ListView.builder(
            shrinkWrap: true,
            itemCount: widget.pickedFile.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(widget.pickedFile[index].path.split('/').last),
                trailing: IconButton(
                  onPressed: () {widget.removeFile(index);},
                  icon: const Icon(CupertinoIcons.delete),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
