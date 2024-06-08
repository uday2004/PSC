import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangeFees extends StatefulWidget {
  const ChangeFees({Key? key}) : super(key: key);

  @override
  State<ChangeFees> createState() => _ChangeFeesState();
}

class _ChangeFeesState extends State<ChangeFees> {
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController feesController = TextEditingController();
  final TextEditingController monthController = TextEditingController();

  String dropdownValue = classList.first;
  String dropdownValueSubject = subjectList.first;
  String dropdownValueMonth = monthList.first;

  static const List<String> classList = <String>['Class 11', 'Class 12', 'CA Foundation'];
  static const List<String> subjectList = <String>['Economics', 'Mathematics'];
  static const List<String> monthList = <String>[
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text('Fees'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            buildDropdownSection(),
            const Divider(),
            buildFeesInputSection(),
            const SizedBox(height: 5),
            buildDueFeesButton(),
            const Divider(),
            buildCurrentFeesSection(),
          ],
        ),
      ),
    );
  }

  Widget buildDropdownSection() {
    return Column(
      children: [
        const Text('Select course', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 20),
        buildDropdownButton(
          value: dropdownValue,
          items: classList,
          onChanged: (value) {
            setState(() {
              dropdownValue = value!;
              classController.text = value;
            });
          },
        ),
        if (classController.text == 'Class 12' || classController.text == 'Class 11') ...[
          const SizedBox(height: 20),
          buildDropdownButton(
            value: dropdownValueSubject,
            items: subjectList,
            onChanged: (value) {
              setState(() {
                dropdownValueSubject = value!;
                subjectController.text = value;
              });
            },
          ),
        ],
      ],
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

  Widget buildFeesInputSection() {
    return Column(
      children: [
        const Text('Fees', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 20),
        TextField(
          controller: feesController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Fees for ${classController.text}',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Colors.orange),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: saveFees,
          child: const Text('Save', style: TextStyle(color: Colors.orangeAccent)),
        ),
      ],
    );
  }

  void saveFees() async {
    if (classController.text.isNotEmpty && feesController.text.isNotEmpty) {
      final fees = int.tryParse(feesController.text);
      if (fees != null) {
        final docRef = FirebaseFirestore.instance.collection('Fees').doc(classController.text);
        final data = classController.text == 'Class 11' || classController.text == 'Class 12'
            ? {subjectController.text: fees}
            : {'Mathematics': fees};
        await docRef.set(data, SetOptions(merge: true));
        feesController.clear();
      } else {
        const Center(child: Text('Invalid fee value'));
      }
    } else {
      const Center(child: Text('Class or Fees is empty'));
    }
  }

  Widget buildDueFeesButton() {
    return ElevatedButton(
      onPressed: openDialog,
      child: const Text('Due fees', style: TextStyle(color: Colors.orangeAccent)),
    );
  }

  Future<void> openDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        String tempDropdownValueMonth = dropdownValueMonth;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Due fees'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildDropdownButton(
                    value: tempDropdownValueMonth,
                    items: monthList,
                    onChanged: (value) {
                      setState(() {
                        tempDropdownValueMonth = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      dropdownValueMonth = tempDropdownValueMonth;
                      monthController.text = tempDropdownValueMonth;
                    });
                    Navigator.pop(context);
                    dueFeesRequest();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> dueFeesRequest() async {
    try {
      // Create a map to accumulate all the data
      Map<String, dynamic> allData = {};

      QuerySnapshot feesQuerySnapshot = await FirebaseFirestore.instance.collection('Fees').get();

      // Process the fetched fees data
      for (var feesDoc in feesQuerySnapshot.docs) {
        Map<String, dynamic> feesData = feesDoc.data() as Map<String, dynamic>;
        String className = feesDoc.id;

        // Add the fees data to the accumulated map
        allData[className] = feesData;
      }

      // Save the accumulated fees data
      int year = DateTime.now().year;
      final db = FirebaseFirestore.instance.collection('Fees_due').doc('${monthController.text.trim()}_$year');
      await db.set(allData, SetOptions(merge: true));

      // Fetch and add user data to the sub-collection
      QuerySnapshot usersQuerySnapshot = await FirebaseFirestore.instance.collection('Users').get();

      for (var userDoc in usersQuerySnapshot.docs) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String userUid = userDoc.id;

        if(userData['Status'] == 'Active' && userData['role'] == 'Student'){
          // Add user data to the sub-collection
          await db.collection('Users').doc(userUid).set({
            'Name': '${userData['First Name']} ${userData['Last Name']}',
            'Course': userData['Course'],
            'Subject': userData['Subject'],
            'Month': '${monthController.text.trim()}_$year',
            'UID': userUid,
            'Status': 'Pending',
          });
        }
      }

      Get.snackbar(
        "Success", "Fees made due",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Failed", "Unable to due fees",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }


  Widget buildCurrentFeesSection() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Fees').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final feesDocs = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: feesDocs.length,
            itemBuilder: (context, index) {
              final data = feesDocs[index].data() as Map<String, dynamic>;
              final className = feesDocs[index].id;
              return ListTile(
                title: Text(className),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data['Economics'] != null) Text('Economics: ₹${data['Economics']}'),
                    if (data['Mathematics'] != null) Text('Mathematics: ₹${data['Mathematics']}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
