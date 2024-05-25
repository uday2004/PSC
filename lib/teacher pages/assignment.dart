import 'dart:io';
import 'dart:typed_data';

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
  String dropdownValue = list.first;
  static const List<String> list = <String>['Class 11', 'Class 12', 'CA Foundation'];
  List<String> existingFiles = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    courseController.text = dropdownValue;
    loadExistingFiles();
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
                  loadExistingFiles();
                },
                items: list.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                value: dropdownValue,
              ),
              const SizedBox(height: 20,),
              const Text("Uploaded Files:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10,),
              isLoading
                  ? const CircularProgressIndicator()
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: existingFiles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(existingFiles[index]),
                    trailing: IconButton(
                      icon: const Icon(CupertinoIcons.delete),
                      onPressed: () => deleteExistingFile(existingFiles[index]),
                    ),
                  );
                },
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
          loadExistingFiles();
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
              .child("Assignments/${courseController.text}/${file.name}");
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
    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadExistingFiles() async {
    try {
      setState(() {
        isLoading = true;
      });
      final listRef = FirebaseStorage.instance.ref().child("Assignments/${courseController.text}");
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
      final ref = FirebaseStorage.instance.ref().child("Assignments/${courseController.text}/$fileName");
      await ref.delete();
      loadExistingFiles();
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
