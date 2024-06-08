import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Classes extends StatefulWidget {
  const Classes({super.key});

  @override
  State<Classes> createState() => _ClassesState();
}

class _ClassesState extends State<Classes> {
  TextEditingController optionController = TextEditingController();
  String dropDownValue = list.first;
  static const List<String> list = <String>['Recorded Classes', 'Meeting Link'];

  late String userClass = '';
  late String userSub = '';
  late String userBoard = '';
  bool isLoading = true;
  List<String> existingFiles = [];

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
            isLoading = false;
          });
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

      final listRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("Recorded Classes/$userClass");

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

  Future<void> downloadFile(String fileName) async {
    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("Recorded Classes/$userClass/$fileName");
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
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
                    dropDownValue = value!;
                    optionController.text = value;
                  });
                },
                items: list.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                value: dropDownValue,
              ),
              const SizedBox(height: 15),
              Text(optionController.text, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              Expanded(
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
      ),
    );
  }

  Stream<List<String>> _fileListStream() async* {
    while (true) {
      if (dropDownValue == "Recorded Classes") {
        List<String> files = await _loadExistingFiles();
        yield files;
      } else if (dropDownValue == "Meeting Link") {
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
          .doc(userClass)
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
      final listRef = firebase_storage.FirebaseStorage.instance.ref().child("Recorded Classes/$userClass");
      final firebase_storage.ListResult result = await listRef.listAll();
      return result.items.map((item) => item.name).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading files: $e')),
      );
      return [];
    }
  }

  Widget _display(List<String> items) {
    if (dropDownValue == "Recorded Classes") {
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item),
            trailing: IconButton(
              icon: const Icon(CupertinoIcons.down_arrow),
              onPressed: () async {
                await _downloadFile(item);
              },
            ),
          );
        },
      );
    } else if (dropDownValue == "Meeting Link") {
      return _displayMeetingLinks();
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _displayMeetingLinks() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Meeting Links")
          .doc(userClass)
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
        return ListView(
          children: docs.map((doc) {
            String title = doc['Topic'];
            String link = doc['Meeting Link'];
            String fromTime = doc['From'];
            String toTime = doc['To'];
            String pin = doc['Password'];
            return ListTile(
              title: Text("Topic: $title"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Link: $link"),
                  Text("From: $fromTime"),
                  Text("To: $toTime"),
                  Text("Password: $pin"),
                  const Divider(),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _downloadFile(String fileName) async {
    try {
      final ref = firebase_storage.FirebaseStorage.instance.ref().child("Recorded Classes/$userClass/$fileName");
      final Directory tempDir = await getTemporaryDirectory();
      final String tempFilePath = '${tempDir.path}/$fileName';
      await ref.writeToFile(File(tempFilePath));
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = '${appDocDir.path}/$fileName';
      final File tempFile = File(tempFilePath);
      await tempFile.copy(appDocPath);
      await tempFile.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File downloaded successfully')),
      );
    } catch (e) {
      Text(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e')),
      );
    }
  }
}