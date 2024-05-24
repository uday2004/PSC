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
  late String userClass;
  List<String> existingFiles = [];

  @override
  void initState() {
    super.initState();
    _getUserClass();
  }

  Future<void> _getUserClass() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();

      Map<String, dynamic>? userData = docSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        setState(() {
          userClass = userData['Course'];
        });
        loadExistingFiles(); // Load existing files once user class is fetched
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildStudyMaterialList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyMaterialList() {
    return ListView.builder(
      itemCount: existingFiles.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(existingFiles[index]),
          trailing: IconButton(
            icon: const Icon(CupertinoIcons.down_arrow),
            onPressed: () => downloadFile(existingFiles[index]),
          ),
        );
      },
    );
  }

  Future<void> loadExistingFiles() async {
    try {
      final listRef = firebase_storage.FirebaseStorage.instance.ref().child("Study Material/$userClass");
      final firebase_storage.ListResult result = await listRef.listAll();
      setState(() {
        existingFiles = result.items.map((item) => item.name).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading files: $e')),
      );
    }
  }

  Future<File?> downloadFile(String fileName) async {
    try {
      // Get a reference to the file
      final ref = firebase_storage.FirebaseStorage.instance.ref().child("Study Material/$fileName/");

      // Create a temporary directory to store the downloaded file
      late Directory tempDir;
      tempDir = await getTemporaryDirectory();
      final String tempFilePath = '${tempDir.path}/$fileName';

      // Download the file to the temporary directory
      await ref.writeToFile(File(tempFilePath));

      // Define a path in the application documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = '${appDocDir.path}/$fileName';

      // Move the file from the temporary directory to the permanent directory
      final File tempFile = File(tempFilePath);
      await tempFile.copy(appDocPath);

      // Delete the temporary file
      await tempFile.delete();

      // Return the file path of the downloaded file in the permanent directory
      return File(appDocPath);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading files: $e')),
      );
      return null;
    }
  }
}
