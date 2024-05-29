import 'dart:io';
import 'dart:typed_data' as typed_data;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/meeting_link_model.dart';
import '../repository/meeting_link_repository.dart';

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

  final linkRepo = Get.put(MeetingLinkRepository());

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    courseController.text = dropdownValue;
    optionController.text = dropdownValueOption;
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
                  underline: Container(
                    height: 2,
                    color: Colors.orangeAccent,
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      dropdownValue = value!;
                      courseController.text = value;
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
                      dropdownValueOption = value!;
                      optionController.text = value;
                    });
                  },
                  items: listOption.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  value: dropdownValueOption,
                ),
                const SizedBox(height: 15),
                Text(optionController.text, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 10),
                isLoading
                    ? const CircularProgressIndicator()
                    : Expanded(
                  child: StreamBuilder<List<String>>(
                    stream: _fileListStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: _uploadMediaButton(context),
          ),
        ],
      ),
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
    }
  }

  Future<void> openDialog() async {
    TextEditingController titleController = TextEditingController();
    TextEditingController linkController = TextEditingController();
    TextEditingController fromTimeController = TextEditingController();
    TextEditingController toTimeController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Meeting Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            TextField(
              controller: linkController,
              decoration: const InputDecoration(hintText: 'Link'),
            ),
            TextField(
              controller: fromTimeController,
              decoration: const InputDecoration(hintText: 'Class starts from'),
            ),
            TextField(
              controller: toTimeController,
              decoration: const InputDecoration(hintText: 'Class ends by'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(hintText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String title = titleController.text.trim();
              String link = linkController.text.trim();
              String fromTime = fromTimeController.text.trim();
              String toTime = toTimeController.text.trim();
              String password = passwordController.text.trim();
              if (title.isNotEmpty && link.isNotEmpty && toTime.isNotEmpty && fromTime.isNotEmpty && password.isNotEmpty) {
                final meetingLink = MeetingLink(
                  topic: title,
                  meetingLink: link,
                  fromTime: fromTime,
                  toTime: toTime,
                  password: password,
                );
                String uid = courseController.text.trim();
                await linkRepo.createLink(meetingLink, uid);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
      final listRef = FirebaseStorage.instance.ref().child("Recorded Classes/${courseController.text}");
      final ListResult result = await listRef.listAll();
      return result.items.map((item) => item.name).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading files: $e')),
      );
      return [];
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
      return Container(
        child: lookDisplay(),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget lookDisplay() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Meeting Links")
          .doc(courseController.text)
          .collection("Links")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text('Error loading links');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No links found');
        }
        List<DocumentSnapshot> docs = snapshot.data!.docs;
        return Column(
          children: docs.map((doc) {
            String title = doc['Topic'];
            String link = doc['Meeting Link'];
            String fromTime = doc['From'];
            String toTime = doc['To'];
            String pin = doc['Password'];
            return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(title),
                  Text(link),
                  Text(fromTime),
                  Text(toTime),
                  Row(
                    children: [
                      Text(pin),
                      IconButton(
                        onPressed: () async {
                          deleteExistingFile(item);
                        };
                        icon: const Icon(CupertinoIcons.delete),
                      )
                    ],
                  )
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> deleteExistingFile(String itemName) async {
    try {
      setState(() {
        isLoading = true;
      });
      if (dropdownValueOption == "Recorded Classes") {
        final ref = FirebaseStorage.instance
            .ref()
            .child("Recorded Classes/${courseController.text}/$itemName");
        await ref.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File deleted successfully')),
        );
      } else if (dropdownValueOption == "Meeting Link") {
        await FirebaseFirestore.instance
            .collection("Meeting Links")
            .doc(courseController.text)
            .collection("Links")
            .doc(itemName)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link deleted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting item: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
