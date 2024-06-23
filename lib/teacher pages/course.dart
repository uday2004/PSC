import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:psc/teacher%20pages/course_details.dart';

class Course extends StatefulWidget {
  const Course({super.key});

  @override
  State<Course> createState() => _CourseState();
}

class _CourseState extends State<Course> {
  TextEditingController classController = TextEditingController();
  TextEditingController subjectController = TextEditingController();

  List<String> list = ['Class', 'Custom'];
  static const List<String> classOption = [
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
    'Class 11',
    'Class 12'
  ];
  static const List<String> subjectOption = [
    'Mathematics',
    'Economics',
    'Both(Mathematics & Economics)',
    'Computer',
    'Science',
    'Commerce',
    'All'
  ];

  String dropdownValue = 'Class';
  String dropdownValueClass = classOption[0];
  String dropdownValueSubject = subjectOption[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('Current Course'),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.secondary,
          ),
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('Course').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading data'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No data found'));
                    }

                    final classData = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: classData.length,
                      itemBuilder: (BuildContext context, int index) {
                        final docId = classData[index].id;
                        return ListTile(
                          title: Text(
                            docId,
                            style: const TextStyle(fontSize: 18),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CourseDetails(courseId: docId),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Add New Course'),
                    content: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('Class'),
                            leading: Radio<String>(
                              value: list[0],
                              groupValue: dropdownValue,
                              onChanged: (String? value) {
                                setState(() {
                                  dropdownValue = value!;
                                });
                              },
                            ),
                          ),
                          ListTile(
                            title: const Text('Custom'),
                            leading: Radio<String>(
                              value: list[1],
                              groupValue: dropdownValue,
                              onChanged: (String? value) {
                                setState(() {
                                  dropdownValue = value!;
                                });
                              },
                            ),
                          ),
                          if (dropdownValue == 'Class') ...[
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
                                  dropdownValueClass = value!;
                                  classController.text = value;
                                });
                              },
                              items: classOption.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                              value: dropdownValueClass,
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
                              items: subjectOption.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                              value: dropdownValueSubject,
                            ),
                          ] else ...[
                            TextFormField(
                              controller: classController,
                              decoration: InputDecoration(
                                labelText: 'Course Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
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
                              items: subjectOption.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                              value: dropdownValueSubject,
                            ),
                          ]
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          List<String> subjectsToAdd;
                          if (dropdownValueSubject == 'Both(Mathematics & Economics)') {
                            subjectsToAdd = ['Mathematics', 'Economics'];
                          } else if (dropdownValueSubject == 'All') {
                            subjectsToAdd = ['Mathematics', 'Economics','Computer', 'Science', 'Commerce'];
                          }else{
                          subjectsToAdd = [dropdownValueSubject];
                          }

                          String courseId = dropdownValue == 'Class'
                          ? dropdownValueClass
                              : classController.text;

                          // Adding the data to course
                          await FirebaseFirestore.instance
                              .collection('Course')
                              .doc(courseId)
                              .set({
                          'Subject': subjectsToAdd,
                          'Board': dropdownValue == 'Class'
                          ? ['ISC', 'CBSE', 'West Bengal']
                              : ['NA'],
                          });

                          // Adding the data to the fees
                          for (String subject in subjectsToAdd) {
                          await FirebaseFirestore.instance
                              .collection('Fees')
                              .doc(courseId)
                              .set({
                          subject: 0,
                          }, SetOptions(merge: true));
                          }

                          Navigator.of(context).pop();
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: const Icon(CupertinoIcons.pencil),
      ),
    );
  }
}
