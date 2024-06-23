import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Assignment extends StatefulWidget {
  const Assignment({Key? key}) : super(key: key);

  @override
  State<Assignment> createState() => _AssignmentState();
}

class _AssignmentState extends State<Assignment> {
  String? userClass;
  String? userBoard;
  List<String> userSubjects = [];
  Map<String, List<String>> subjectAssignments = {};
  Map<String, bool> isExpanded = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Assignments',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(child: _buildAssignmentList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentList() {
    return ListView.builder(
      itemCount: userSubjects.length,
      itemBuilder: (context, index) {
        final subject = userSubjects[index];
        final assignments = subjectAssignments[subject] ?? [];
        final isExpandedSubject = isExpanded[subject] ?? false;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(
                subject,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                _toggleExpansion(subject);
              },
            ),
            if (isExpandedSubject && assignments.isNotEmpty)
              Column(
                children: assignments
                    .map(
                      (fileName) => ListTile(
                    title: TextButton(
                      onPressed: () {
                        _openFileFromGCS(fileName, index); // Pass index for subject
                      },
                      child: Text(fileName,style: const TextStyle(color: Colors.orange),),
                    ),
                    trailing: IconButton(
                      icon: const Icon(CupertinoIcons.down_arrow),
                      onPressed: () {
                        _downloadFileFromGCS(fileName, index); // Pass index for subject
                      },
                    ),
                  ),
                )
                    .toList(),
              )
            else if (isExpandedSubject && assignments.isEmpty)
              const ListTile(title: Text('No assignments available')),
            const Divider(),
          ],
        );
      },
    );
  }

  Future<void> _downloadFileFromGCS(String fileName, int subjectIndex) async {
    try {
      final subject = userSubjects[subjectIndex];
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("Assignments/$userClass/$userBoard/$subject/$fileName");

      final Directory appStorage;
      if (kIsWeb) {
        throw UnsupportedError("Downloading files is not supported on the web.");
      } else if (Platform.isAndroid || Platform.isIOS) {
        appStorage = (await getExternalStorageDirectory())!;
      } else {
        appStorage = await getApplicationDocumentsDirectory();
      }

      final localFile = File('${appStorage.path}/$fileName');

      await ref.writeToFile(localFile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File downloaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e')),
      );
      print('Error downloading file: $e');
    }
  }

  Future<void> _openFileFromGCS(String fileName, int index) async {
    try {
      final subject = userSubjects[index];
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("Assignments/$userClass/$userBoard/$subject/$fileName");

      final Directory appStorage;
      if (kIsWeb) {
        throw UnsupportedError("Opening files is not supported on the web.");
      } else if (Platform.isAndroid || Platform.isIOS) {
        appStorage = (await getExternalStorageDirectory())!;
      } else {
        appStorage = await getApplicationDocumentsDirectory();
      }

      final localFilePath = '${appStorage.path}/$fileName';
      final localFile = File(localFilePath);

      if (await localFile.exists()) {
        // Open the file from local storage if it exists
        OpenFile.open(localFile.path);
      } else {
        // Download the file from Firebase Storage
        final downloadUrl = await ref.getDownloadURL();
        await Dio().download(downloadUrl, localFilePath);

        // Open the file using open_file package
        OpenFile.open(localFile.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
      print('Error opening file: $e');
    }
  }

  void _toggleExpansion(String subject) {
    setState(() {
      isExpanded[subject] = !(isExpanded[subject] ?? false);
    });
  }

  Future<void> _loadExistingFiles({required String subject}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("Assignments/$userClass/$userBoard/$subject");
      final firebase_storage.ListResult result = await ref.listAll();
      final List<String> files = result.items.map((item) => item.name).toList();

      setState(() {
        subjectAssignments[subject] = files;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading files: $e')),
      );
      print('Error loading files: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getUserData() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      try {
        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .get();

        if (docSnapshot.exists) {
          Map<String, dynamic>? userData = docSnapshot.data() as Map<String, dynamic>?;

          if (userData != null) {
            String? userCourse = userData['Course'] as String?;
            String? userBoard = userData['Board'] as String?;
            List<dynamic> subjectsData = userData['Subject'];
            print(subjectsData);

            if (userCourse != null && userBoard != null && subjectsData != null && subjectsData.isNotEmpty) {
              // Convert the List<dynamic> to List<String>
              List<String> subjects = List<String>.from(subjectsData);

              setState(() {
                userClass = userCourse;
                this.userBoard = userBoard;
                userSubjects = subjects;
                isExpanded.clear(); // Clear existing expansion states
                for (String subject in userSubjects) {
                  isExpanded[subject] = false; // Initialize expansion states
                }
              });

              // Load existing files once user class is fetched
              for (String subject in userSubjects) {
                await _loadExistingFiles(subject: subject);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User data is incomplete')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User data not found')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User document does not exist')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user data: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID is null')),
      );
    }
  }
}
