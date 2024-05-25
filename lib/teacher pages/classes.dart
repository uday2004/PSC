import 'dart:io';
import 'dart:typed_data' as typed_data;

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PiyushClasses extends StatefulWidget {
  const PiyushClasses({Key? key}) : super(key: key);

  @override
  State<PiyushClasses> createState() => _PiyushClassesState();
}

class _PiyushClassesState extends State<PiyushClasses> {
  TextEditingController courseController = TextEditingController();
  String dropdownValue = list.first;
  static const List<String> list = <String>['Class 11', 'Class 12', 'CA Foundation'];

  TextEditingController optionController = TextEditingController();
  String dropdownValueOption = listOption.first;
  static const List<String> listOption = <String>['Recorded Classes', 'Meeting Link'];

  bool isLoading = false;
  List<String> existingFiles = [];

  @override
  void initState() {
    super.initState();
    courseController.text = dropdownValue;
    optionController.text = dropdownValueOption;
    // loadExistingFiles(); // Uncomment and implement this if you need to load files initially
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
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
                    setState(() {
                      dropdownValue = value!;
                      courseController.text = value;
                    });
                    // loadExistingFiles(); // Uncomment if you need to load files on change
                  },
                  items: list.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  value: dropdownValue,
                ),
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
                    setState(() {
                      dropdownValueOption = value!;
                      optionController.text = value;
                    });
                    // loadExistingFiles(); // Uncomment if you need to load files on change
                  },
                  items: listOption.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  value: dropdownValueOption,
                ),
                const SizedBox(height: 15,),
                Text(optionController.text,style: const TextStyle(fontSize: 20),),
                const SizedBox(height: 15,),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return MeetingOption(
                      courseController: courseController,
                      loadExistingFiles: loadExistingFiles,
                    );
                  },
                );
              },
              child: const Icon(Icons.add_call),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<PlatformFile>?> pickFiles(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      withData: true, // Ensure withData is set to true
    );
    if (result != null && result.files.isNotEmpty) {
      return result.files;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No files selected or file paths are null')),
      );
      return null;
    }
  }

  Future<void> uploadFiles(List<PlatformFile> files) async {
    try {
      for (var file in files) {
        typed_data.Uint8List? fileBytes = file.bytes;
        if (fileBytes == null && file.path != null) {
          fileBytes = await File(file.path!).readAsBytes();
        }
        if (fileBytes != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child("Recorded Classes/${courseController.text}/${file.name}");
          await ref.putData(fileBytes);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File uploaded successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File bytes are null')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadExistingFiles() async {
    try {
      setState(() {
        isLoading = true;
      });
      final listRef = FirebaseStorage.instance.ref().child("Recorded Classes/${courseController.text}");
      final ListResult result = await listRef.listAll();
      setState(() {
        existingFiles = result.items.map((item) => item.name).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading files: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteExistingFile(String fileName) async {
    try {
      setState(() {
        isLoading = true;
      });
      final ref = FirebaseStorage.instance.ref().child("Recorded Classes/${courseController.text}/$fileName");
      await ref.delete();
      await loadExistingFiles();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting file: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
