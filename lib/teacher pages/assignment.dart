import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PiyushAssignment extends StatefulWidget {
  const PiyushAssignment({super.key});

  @override
  State<PiyushAssignment> createState() => _PiyushAssignmentState();
}

class _PiyushAssignmentState extends State<PiyushAssignment> {
  TextEditingController courseController = TextEditingController();
  TextEditingController boardController = TextEditingController();
  TextEditingController subjectController = TextEditingController();

  String dropdownValue = '-Select-';
  String dropdownValueSubject = '-Select-';
  String dropdownValueBoard = listBoard.first;

  List<String> classlist = <String>[];
  static const List<String> listBoard = <String>['-Select-', 'ISC', 'CBSE', 'West Bengal'];
  List<String> subjectlist = <String>[];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchClassList();
  }

  Future<void> fetchClassList() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Course').get();
      setState(() {
        classlist = querySnapshot.docs.map((doc) => doc.id).toList();
        if (classlist.isNotEmpty) {
          dropdownValue = classlist.first; // Set default value here
        }
      });
      await fetchSubjectList(dropdownValue);
    } catch (e) {
      print('Error fetching class list: $e');
    }
  }

  Future<void> fetchSubjectList(String selectedClass) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Course')
          .doc(selectedClass)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        List<dynamic> subjectData = docSnapshot['Subject'];
        setState(() {
          subjectlist = subjectData.map((subject) => subject.toString()).toList();
          dropdownValueSubject = subjectlist.isNotEmpty ? subjectlist.first : '-Select-';
          subjectController.text = dropdownValueSubject;
        });
      } else {
        log('No such document or document is empty!');
        setState(() {
          subjectlist = [];
          dropdownValueSubject = '-Select-';
          subjectController.text = dropdownValueSubject;
        });
      }
    } catch (e) {
      log('Error fetching subject list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
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
                    courseController.text = value;
                    fetchSubjectList(value); // Fetch subjects when course changes
                  });
                },
                items: classlist.map<DropdownMenuItem<String>>((String value) {
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
                    dropdownValueSubject = value!;
                    subjectController.text = value;
                  });
                },
                items: subjectlist.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                value: dropdownValueSubject,
              ),
              if (dropdownValue == 'Class 7' || dropdownValue == 'Class 8' || dropdownValue == 'Class 9' || dropdownValue == 'Class 10' || dropdownValue == 'Class 11' || dropdownValue == 'Class 12') ...[
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
                      dropdownValueBoard = value!;
                      boardController.text = value;
                    });
                  },
                  items: listBoard.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  value: dropdownValueBoard,
                ),
              ],
              const SizedBox(height: 20,),
              const Text("Uploaded Files:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10,),
              SizedBox(
                height: 300, // Give a fixed height to ListView
                child: StreamBuilder<List<String>>(
                  stream: _fileListStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Text('Error loading files');
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No files found');
                    }
                    List<String> files = snapshot.data!;
                    return ListView.builder(
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(files[index]),
                          trailing: IconButton(
                            icon: const Icon(CupertinoIcons.delete),
                            onPressed: () => deleteExistingFile(files[index]),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _uploadMediaButton(context),
    );
  }

  Widget _uploadMediaButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
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
      },
      child: const Icon(CupertinoIcons.folder),
    );
  }

  Future<List<PlatformFile>?> pickFiles(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,  // Ensure withData is set to true to get file bytes
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
    for (var file in files) {
      try {
        Uint8List? fileBytes = file.bytes;
        if (fileBytes == null && file.path != null) {
          fileBytes = await File(file.path!).readAsBytes();
        }

        if (fileBytes != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child("Assignments/${courseController.text}/${boardController.text}/${subjectController.text}/${file.name}");
          await ref.putData(fileBytes);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File uploaded successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File bytes are null')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading file: $e')),
        );
      }
    }
  }

  Stream<List<String>> _fileListStream() async* {
    while (true) {
      List<String> files = await _loadExistingFiles();
      yield files;
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Future<List<String>> _loadExistingFiles() async {
    try {
      final listRef = FirebaseStorage.instance.ref().child("Assignments/${courseController.text}/${boardController.text}/${subjectController.text}");
      final ListResult result = await listRef.listAll();
      return result.items.map((item) => item.name).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading files: $e')),
      );
      return [];
    }
  }

  Future<void> deleteExistingFile(String fileName) async {
    try {
      final ref = FirebaseStorage.instance.ref().child("Assignments/${courseController.text}/${boardController.text}/${subjectController.text}/$fileName");
      await ref.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting file: $e')),
      );
    }
  }
}
