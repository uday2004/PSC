import 'dart:io';
import 'dart:typed_data' as typed_data;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../repository/meeting_link_repository.dart';

class PiyushClasses extends StatefulWidget {
  const PiyushClasses({Key? key}) : super(key: key);

  @override
  State<PiyushClasses> createState() => _PiyushClassesState();
}

class _PiyushClassesState extends State<PiyushClasses> {
  TextEditingController courseController = TextEditingController();
  TextEditingController optionController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController boardController = TextEditingController();

  String dropdownValue = list.first;
  String dropdownValueSubject = listOptionSubject.first;
  String dropdownValueBoard = listOptionBoard.first;
  String dropdownValueOption = listOption.first;

  bool isLoading = false;

  static const List<String> list = <String>[
    'Class 11',
    'Class 12',
    'CA Foundation'
  ];
  static const List<String> listOption = <String>[
    'Recorded Classes',
    'Meeting Link'
  ];
  static const List<String> listOptionSubject = <String>[
    'Economics',
    'Mathematics'
  ];
  static const List<String> listOptionBoard = <String>[
    'ISC',
    'CBSE',
    'West Bengal'
  ];

  final linkRepo = Get.put(MeetingLinkRepository());

  @override
  void initState() {
    super.initState();
    courseController.text = dropdownValue;
    optionController.text = dropdownValueOption;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .primary,
      body:
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildDropdownSection(),
            Text(optionController.text,
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            isLoading
                ? const CircularProgressIndicator()
                : Expanded(
              child: Builder(
                builder: (context) {
                  return StreamBuilder<List<String>>(
                    stream: _fileListStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return const Text('Error loading items');
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No items found');
                      }
                      List<String> items = snapshot.data!;
                      return _display(items);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _uploadMediaButton(context),
    );
  }

  Widget buildDropdownButton({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButton<String>(
      isExpanded: true,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      underline: Container(
        height: 2,
        color: Colors.orangeAccent,
      ),
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      value: value,
    );
  }

  Widget buildDropdownSection() {
    return Column(
      children: [
        buildDropdownButton(
          value: dropdownValue,
          items: list,
          onChanged: (value) {
            setState(() {
              dropdownValue = value!;
              courseController.text = value;
            });
          },
        ),
        buildDropdownButton(
            value: dropdownValueOption,
            items: listOption,
            onChanged: (value){
              setState(() {
                dropdownValueOption = value!;
                optionController.text = value;
              });
            }
        ),
        if (courseController.text == 'Class 12' || courseController.text == 'Class 11') ...[
          buildDropdownButton(
            value: dropdownValueSubject,
            items: listOptionSubject,
            onChanged: (value) {
              setState(() {
                dropdownValueSubject = value!;
                subjectController.text = value;
              });
            },
          ),
          buildDropdownButton(
            value: dropdownValueBoard,
            items: listOptionBoard,
            onChanged: (value) {
              setState(() {
                dropdownValueBoard = value!;
                boardController.text = value;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _uploadMediaButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        if (dropdownValueOption == 'Recorded Classes') {
          List<PlatformFile>? selectedFiles = await pickFiles(context);
          if (selectedFiles != null && selectedFiles.isNotEmpty) {
            setState(() {
              isLoading = true;
            });
            await uploadFiles(selectedFiles);
            setState(() {
              isLoading = false;
            });
          }
        } else {
          await openDialog();
        }
      },
      child: const Icon(CupertinoIcons.folder),
    );
  }

  Future<List<PlatformFile>?> pickFiles(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      return result.files;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No files selected or file paths are null')),
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
              .child(
              "Recorded Classes/${courseController.text}/${boardController
                  .text}/${subjectController.text}/${file.name}");
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
    }
  }

  Future<void> openDialog() async {
    // Same code as before, no changes needed
  }

  Stream<List<String>> _fileListStream() async* {
    while (true) {
      if (dropdownValueOption == "Recorded Classes") {
        List<String> files = await _loadExistingFiles();
        yield files;
      } else if (dropdownValueOption == "Meeting Link") {
        List<String> links = await _loadExistingLinks();
        yield links;
      }
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Future<List<String>> _loadExistingLinks() async {
    try {
      final listLinks = await FirebaseFirestore.instance
          .collection("Meeting Links")
          .doc(courseController.text)
          .collection("Links")
          .get();
      return listLinks.docs.map((doc) => doc.id).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading links: $e')),
      );
      return [];
    }
  }

  Future<List<String>> _loadExistingFiles() async {
    try {
      final listRef = FirebaseStorage.instance.ref().child(
          "Recorded Classes/${courseController.text}/${boardController
              .text}/${subjectController.text}");
      final ListResult result = await listRef.listAll();
      return result.items.map((item) => item.name).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading files: $e')),
      );
      return [];
    }
  }

  Future<void> deleteExistingFile(String itemName) async {
    try {
      setState(() {
        isLoading = true;
      });
      if (dropdownValueOption == "Recorded Classes") {
        final ref = FirebaseStorage.instance
            .ref()
            .child("Recorded Classes/${courseController.text}/${boardController
            .text}/${subjectController.text}/$itemName");
        await ref.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File deleted successfully')),
        );
      }
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

  Widget _display(List<String> items) {
    if (dropdownValueOption == "Recorded Classes") {
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await deleteExistingFile(item);
              },
            ),
          );
        },
      );
    } else if (dropdownValueOption == "Meeting Link") {
      // Implement the display for meeting links
      // Example:
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await deleteExistingLink(item); // Assuming item is the docId
              },
            ),
          );
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }


  Future<void> deleteExistingLink(String docId) async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection("Meeting Links")
          .doc(courseController.text)
          .collection("Links")
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting link: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}