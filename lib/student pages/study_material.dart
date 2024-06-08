import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class StudyMaterial extends StatefulWidget {
  const StudyMaterial({Key? key}) : super(key: key);

  @override
  _StudyMaterialState createState() => _StudyMaterialState();
}

class _StudyMaterialState extends State<StudyMaterial> {
  late String userClass = '';
  late String userSub = '';
  late String userBoard = '';
  List<String> existingFiles = [];
  bool isLoading = false;
  String currentSubject = '';

  @override
  void initState() {
    super.initState();
    _getUserClass();
  }

  Future<void> _getUserClass() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      try {
        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .get();

        Map<String, dynamic>? userData = docSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          setState(() {
            userClass = userData['Course'];
            userSub = userData['Subject'];
            userBoard = userData['Board'];
          });
          loadExistingFiles(); // Load existing files once user class is fetched
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user data: $e')),
        );
      }
    }
  }

  Future<void> loadExistingFiles({String subject = ''}) async {
    try {
      setState(() {
        isLoading = true;
        currentSubject = subject;
      });

      final List<firebase_storage.Reference> references = [];

      if (userClass == 'Class 11' || userClass == 'Class 12') {
        if (subject.isNotEmpty) {
          references.add(firebase_storage.FirebaseStorage.instance
              .ref()
              .child("Study Material/$userClass/$userBoard/$subject"));
        } else if (userSub == 'Economics' || userSub == 'Mathematics') {
          references.add(firebase_storage.FirebaseStorage.instance
              .ref()
              .child("Study Material/$userClass/$userBoard/$userSub"));
        } else if (userSub == 'Both(Maths & Economics)') {
          setState(() {
            existingFiles = ['Mathematics', 'Economics'];
          });
          return;
        }

        final List<String> files = [];
        for (final ref in references) {
          final firebase_storage.ListResult result = await ref.listAll();
          files.addAll(result.items.map((item) => item.name));
        }

        setState(() {
          existingFiles = files;
        });
      }

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

  Future<void> downloadFile(String fileName) async {
    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("Study Material/$userClass/$userBoard/$currentSubject/$fileName");
      final Directory tempDir = await getTemporaryDirectory();
      final String tempFilePath = '${tempDir.path}/$fileName';
      await ref.writeToFile(File(tempFilePath));
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = '${appDocDir.path}/$fileName';
      final File tempFile = File(tempFilePath);
      await tempFile.copy(appDocPath);
      await tempFile.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File downloaded to $appDocPath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              'Study Materials',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            if (currentSubject.isNotEmpty)
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        currentSubject = '';
                        existingFiles = ['Mathematics', 'Economics'];
                      });
                    },
                  ),
                  Text(
                    currentSubject,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(child: _buildStudyMaterialList()),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyMaterialList() {
    return RefreshIndicator(
      onRefresh: () => loadExistingFiles(subject: currentSubject),
      child: existingFiles.isEmpty
          ? const Center(child: Text('No study materials available'))
          : ListView.builder(
        itemCount: existingFiles.length,
        itemBuilder: (context, index) {
          if (userSub == 'Both(Maths & Economics)' && currentSubject.isEmpty) {
            return ListTile(
              title: Text(existingFiles[index]),
              onTap: () => loadExistingFiles(subject: existingFiles[index]),
            );
          } else {
            return ListTile(
              title: Text(existingFiles[index]),
              trailing: IconButton(
                icon: const Icon(CupertinoIcons.down_arrow),
                onPressed: () => downloadFile(existingFiles[index]),
              ),
            );
          }
        },
      ),
    );
  }
}
