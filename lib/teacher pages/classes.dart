import 'dart:developer';
import 'dart:typed_data' as typed_data;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:psc/repository/meeting_link_repository.dart';
import 'package:intl/intl.dart';

class PiyushClasses extends StatefulWidget {
  const PiyushClasses({Key? key}) : super(key: key);

  @override
  State<PiyushClasses> createState() => _PiyushClassesState();
}

class _PiyushClassesState extends State<PiyushClasses> {
  final FirebaseServices firebaseServices = FirebaseServices();
  TextEditingController courseController = TextEditingController();
  TextEditingController optionController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController boardController = TextEditingController();

  String dropdownValue = '';
  String dropdownValueSubject = '';
  String dropdownValueBoard = listOptionBoard.first;
  String dropdownValueOption = listOption.first;

  bool isLoading = false;

  List<String> list = <String>[];
  static const List<String> listOption = <String>[
    'Meeting Link',
    'Recorded Classes',
  ];
  List<String> listOptionSubject = <String>[];
  static const List<String> listOptionBoard = <String>[
    '-Select-',
    'ISC',
    'CBSE',
    'West Bengal'
  ];

  @override
  void initState() {
    super.initState();
    optionController.text = dropdownValueOption;
    fetchClassList();
  }

  @override
  void dispose() {
    courseController.dispose();
    optionController.dispose();
    subjectController.dispose();
    boardController.dispose();
    super.dispose();
  }

  Future<void> fetchClassList() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Course').get();

      if (!mounted) return;

      if (querySnapshot.docs.isNotEmpty) {
        List<String> courses = querySnapshot.docs.map((doc) => doc.id).toList();

        setState(() {
          list = courses;
          dropdownValue = courses.first; // Set default value to the first course
          courseController.text = dropdownValue;
        });

        // After setting the default value, fetch the subject list for the default course
        await fetchSubjectList(dropdownValue);
      } else {
        setState(() {
          list = [];
          dropdownValue = '-Select-';
          courseController.text = dropdownValue;
        });
      }
    } catch (e) {
      log('Error fetching class list: $e');
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
        if (!mounted) return;
        setState(() {
          listOptionSubject = subjectData.map((subject) => subject.toString()).toList();
          dropdownValueSubject = listOptionSubject.isNotEmpty ? listOptionSubject.first : '-Select-';
          subjectController.text = dropdownValueSubject;
        });
      } else {
        log('No such document or document is empty!');
        if (!mounted) return;
        setState(() {
          listOptionSubject = [];
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
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildDropdownSection(),
            Text(optionController.text, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            isLoading
                ? const CircularProgressIndicator()
                : Expanded(
              child: Builder(
                builder: (context) {
                  return dropdownValueOption == 'Recorded Classes'
                      ? _displayRecordedClasses()
                      : StreamBuilder<QuerySnapshot>(
                    stream: firebaseServices.getMeetingLinks(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return const Text('Error loading items');
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text('No items found');
                      }
                      List<DocumentSnapshot> items = snapshot.data!.docs;
                      return _displayMeetingLinks(items);
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
              fetchSubjectList(value);
            });
          },
        ),
        buildDropdownButton(
            value: dropdownValueOption,
            items: listOption,
            onChanged: (value) {
              setState(() {
                dropdownValueOption = value!;
                optionController.text = value;
              });
            }),
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
        if (dropdownValue == 'Class 7' ||
            dropdownValue == 'Class 8' ||
            dropdownValue == 'Class 9' ||
            dropdownValue == 'Class 10' ||
            dropdownValue == 'Class 11' ||
            dropdownValue == 'Class 12') ...[
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
        const SnackBar(content: Text('No files selected or file paths are null')),
      );
      return null;
    }
  }

  Future<void> uploadFiles(List<PlatformFile> files) async {
    try {
      for (var file in files) {
        if (file.bytes != null) {
          await uploadToFirebase(file.bytes!, file.name);
        }
      }
    } catch (e) {
      log('Error uploading files: $e');
    }
  }

  Future<void> uploadToFirebase(typed_data.Uint8List data, String fileName) async {
    try {
      String filePath = 'Recorded Classes/${courseController.text}/${boardController.text}/${subjectController.text}/$fileName';
      Reference ref = FirebaseStorage.instance.ref().child(filePath);
      await ref.putData(data);
    } catch (e) {
      log('Error uploading to Firebase: $e');
    }
  }

  Future<void> openDialog() async {
    final meetingLinkController = TextEditingController();
    final passwordController = TextEditingController();
    final topicController = TextEditingController();

    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Meeting Link Form'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: meetingLinkController,
                decoration: const InputDecoration(labelText: 'Room ID'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              TextField(
                controller: topicController,
                decoration: const InputDecoration(labelText: 'Topic'),
              ),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                ),
                controller: TextEditingController(
                  text: '${selectedDate.day}-${selectedDate.month}-${selectedDate.year}',
                ),
              ),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Time',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null && picked != selectedTime) {
                        setState(() {
                          selectedTime = picked;
                        });
                      }
                    },
                  ),
                ),
                controller: TextEditingController(
                  text: '${selectedTime.hour}:${selectedTime.minute}',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await firebaseServices.saveMeetingLink(
                meetingLinkController.text,
                passwordController.text,
                topicController.text,
                selectedDate,
                selectedTime,
                courseController.text.trim(),
                subjectController.text.trim()
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _displayRecordedClasses() {
    return FutureBuilder<ListResult>(
      future: FirebaseStorage.instance
          .ref('Recorded Classes/${courseController.text}/${boardController.text}/${subjectController.text}')
          .listAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text('Error loading files');
        }
        if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
          return const Text('No files found');
        }

        List<Reference> items = snapshot.data!.items;
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return FutureBuilder<String>(
              future: items[index].getDownloadURL(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }
                if (snapshot.hasError) {
                  return const Text('Error loading file URL');
                }
                if (!snapshot.hasData) {
                  return const Text('No URL found for file');
                }

                return Card(
                  elevation: 5,
                  child: ListTile(
                    title: Text(items[index].name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteFile(items[index]);
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _deleteFile(Reference fileRef) async {
    try {
      await fileRef.delete();
      setState(() {});
    } catch (e) {
      log('Error deleting file: $e');
    }
  }

  Widget _displayMeetingLinks(List<DocumentSnapshot> items) {
    return SizedBox(
      height: 400.0,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> data = items[index].data() as Map<String, dynamic>;
          DateTime dateTime = data['date'] != null
              ? (data['date'] as Timestamp).toDate()
              : DateTime.now();
          String formattedDate = DateFormat('dd-MM-yyyy – kk:mm').format(dateTime);

          // Check if the meeting link matches the selected course and subject
          if (data['course'] == courseController.text && data['subject'] == subjectController.text) {
            return Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['topic'] ?? 'No topic',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text('Room ID: ${data['meetingLink']}'),
                    const SizedBox(height: 5),
                    Text('Password: ${data['password']}'),
                    const SizedBox(height: 5),
                    Text('Date and time: $formattedDate'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            openUpdateDialog(items[index]);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await firebaseServices.deleteMeetingLink(items[index].id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text(' '),); // Return an empty widget for non-matching items
          }
        },
      ),
    );
  }

  Future<void> openUpdateDialog(DocumentSnapshot docSnapshot) async {
    final meetingLinkController = TextEditingController(text: docSnapshot['meetingLink'] ?? '');
    final passwordController = TextEditingController(text: docSnapshot['password'] ?? '');
    final topicController = TextEditingController(text: docSnapshot['topic'] ?? '');

    DateTime selectedDate = (docSnapshot['date'] as Timestamp).toDate();
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Meeting Link'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: meetingLinkController,
                decoration: const InputDecoration(labelText: 'Room ID'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              TextField(
                controller: topicController,
                decoration: const InputDecoration(labelText: 'Topic'),
              ),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                ),
                controller: TextEditingController(
                  text: '${selectedDate.day}-${selectedDate.month}-${selectedDate.year}',
                ),
              ),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Time',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null && picked != selectedTime) {
                        setState(() {
                          selectedTime = picked;
                        });
                      }
                    },
                  ),
                ),
                controller: TextEditingController(
                  text: '${selectedTime.hour}:${selectedTime.minute}',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await firebaseServices.updateMeetingLink(
                docSnapshot.id,
                meetingLinkController.text,
                passwordController.text,
                topicController.text,
                selectedDate,
                selectedTime,
              );
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class FirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getMeetingLinks() {
    // Order by 'date' field in descending order
    return _firestore.collection('MeetingLinks').orderBy('date', descending: true).snapshots();
  }

  Future<void> saveMeetingLink(String meetingLink, String password, String topic, DateTime date, TimeOfDay time, String course, String subject) async {
    try {
      await _firestore.collection('MeetingLinks').add({
        'meetingLink': meetingLink,
        'password': password,
        'topic': topic,
        'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day, time.hour, time.minute)),
        'course': course,
        'subject': subject,
      });
    } catch (e) {
      log('Error saving meeting link: $e');
    }
  }

  Future<void> updateMeetingLink(String id, String meetingLink, String password, String topic, DateTime date, TimeOfDay time) async {
    try {
      await _firestore.collection('MeetingLinks').doc(id).update({
        'meetingLink': meetingLink,
        'password': password,
        'topic': topic,
        'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day, time.hour, time.minute)),
      });
    } catch (e) {
      log('Error updating meeting link: $e');
    }
  }

  Future<void> deleteMeetingLink(String id) async {
    try {
      await _firestore.collection('MeetingLinks').doc(id).delete();
    } catch (e) {
      log('Error deleting meeting link: $e');
    }
  }
}
