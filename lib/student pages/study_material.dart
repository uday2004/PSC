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
  bool isLoading = false;

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

  Future<void> loadExistingFiles() async {
    try {
      setState(() {
        isLoading = true;
      });
      final listRef = firebase_storage.FirebaseStorage.instance.ref().child("Study Material/$userClass");
      final firebase_storage.ListResult result = await listRef.listAll();
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

  Future<File?> downloadFile(String fileName) async {
    try {
      final ref = firebase_storage.FirebaseStorage.instance.ref().child("Study Material/$userClass/$fileName");
      final Directory tempDir = await getTemporaryDirectory();
      final String tempFilePath = '${tempDir.path}/$fileName';
      await ref.writeToFile(File(tempFilePath));
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = '${appDocDir.path}/$fileName';
      final File tempFile = File(tempFilePath);
      await tempFile.copy(appDocPath);
      await tempFile.delete();
      return File(appDocPath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e')),
      );
      return null;
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
            const Text(
              'Study Materials',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
      onRefresh: loadExistingFiles,
      child: existingFiles.isEmpty
          ? Center(child: Text('No study materials available'))
          : ListView.builder(
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
      ),
    );
  }
}
