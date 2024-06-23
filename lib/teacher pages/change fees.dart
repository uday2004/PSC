import 'dart:async';
import 'dart:developer';
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

  String dropdownValue = '-Select-';
  String dropdownValueSubject = '-Select-';
  String dropdownValueMonth = monthList.first;

  List<String> classList = [];
  List<String> subjectList = [];
  static const List<String> monthList = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    fetchClassList();
  }

  Future<void> fetchClassList() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Course').get();
      setState(() {
        classList = querySnapshot.docs.map((doc) => doc.id).toList();
        if (classList.isNotEmpty) {
          dropdownValue = classList.first; // Set default value here
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
        // Convert dynamic list to List<String>
        List<dynamic> subjectData = docSnapshot['Subject'];
        setState(() {
          subjectList = List<String>.from(subjectData);
          dropdownValueSubject = subjectList.isNotEmpty ? subjectList.first : '-Select-';
          subjectController.text = dropdownValueSubject;
        });
      } else {
        log('No such document or document is empty!');
        setState(() {
          subjectList = [];
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
              fetchSubjectList(value); // Fetch subjects for the selected class
            });
          },
        ),
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
          child: const Text(
              'Save', style: TextStyle(color: Colors.orangeAccent)),
        ),
      ],
    );
  }

  Future<void> saveFees() async {
    // Check if class or fees is empty
    if (classController.text.isEmpty || feesController.text.isEmpty) {
      Get.snackbar(
        "Error", "Class or Fees cannot be empty",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Parse fees to an integer
    final fees = int.tryParse(feesController.text);
    if (fees == null) {
      Get.snackbar(
        "Error", "Invalid fee value",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Prepare data to be saved
      final docRef = FirebaseFirestore.instance.collection('Fees').doc(classController.text);
      Map<String, dynamic> data;

      // Retrieve old fees from Firestore
      final docSnapshot = await docRef.get();
      final oldData = docSnapshot.data() as Map<String, dynamic>?;

      // Include old fees if available
      int oldMathFees = oldData?['Mathematics'] ?? 0;
      int oldEconFees = oldData?['Economics'] ?? 0;
      int oldCommFees = oldData?['Commerce'] ?? 0;
      int oldComFees = oldData?['Computer'] ?? 0;
      int oldSciFees = oldData?['Science'] ?? 0;

      // Include fees for both Mathematics and Economics
      data = {
        'Mathematics': dropdownValueSubject == 'Mathematics' ? fees : oldMathFees,
        'Economics': dropdownValueSubject == 'Economics' ? fees : oldEconFees,
        'Commerce': dropdownValueSubject == 'Commerce' ? fees : oldCommFees,
        'Computer': dropdownValueSubject == 'Computer' ? fees : oldComFees,
        'Science': dropdownValueSubject == 'Science' ? fees : oldSciFees,
      };

      // Save data to Firestore
      await docRef.set(data, SetOptions(merge: true));

      // Clear input fields
      feesController.clear();

      // Show success message
      Get.snackbar(
        "Success", "Fees saved successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Show error message
      Get.snackbar(
        "Error", "Failed to save fees: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget buildDueFeesButton() {
    return ElevatedButton(
      onPressed: openDialog,
      child: const Text(
          'Due fees', style: TextStyle(color: Colors.orangeAccent)),
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
                  const Text('Select month'),
                  DropdownButton<String>(
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    underline: Container(
                      height: 2,
                      color: Colors.orangeAccent,
                    ),
                    onChanged: (value) {
                      setState(() {
                        tempDropdownValueMonth = value!;
                      });
                    },
                    items: monthList.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    value: tempDropdownValueMonth,
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
      // Fetch all fees data
      QuerySnapshot feesQuerySnapshot = await FirebaseFirestore.instance.collection('Fees').get();

      // Accumulate fees data
      Map<String, dynamic> allData = {};
      for (var feesDoc in feesQuerySnapshot.docs) {
        Map<String, dynamic> feesData = feesDoc.data() as Map<String, dynamic>;
        String className = feesDoc.id;
        allData[className] = feesData;
      }

      // Get the current year and month
      int year = DateTime.now().year;
      String monthYearKey = '${monthController.text.trim()}_$year';

      // Reference to the Fees_due collection for the current month and year
      final feesDueDoc = FirebaseFirestore.instance.collection('Fees_due').doc(monthYearKey);

      // Check if the month and year already exist in Fees_due collection
      DocumentSnapshot feesDueSnapshot = await feesDueDoc.get();
      if (feesDueSnapshot.exists) {
        // Fetch all users data in Fees_due for the current month and year
        QuerySnapshot usersDueQuerySnapshot = await feesDueDoc.collection('Users').get();
        Set<String> existingUserIds = usersDueQuerySnapshot.docs.map((doc) => doc.id).toSet();

        // Fetch all users data from Users collection
        QuerySnapshot usersQuerySnapshot = await FirebaseFirestore.instance.collection('Users').get();

        // Process each user
        for (var userDoc in usersQuerySnapshot.docs) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          String userUid = userDoc.id;

          // Check if user is an active student and does not already exist in Fees_due collection
          if (userData['Status'] == 'Active' && userData['role'] == 'Student' && !existingUserIds.contains(userUid)) {
            String course = userData['Course'];
            List<String> subjects = (userData['Subject'] as List<dynamic>)
                .map((subject) => subject.toString().trim())
                .toList(); // Convert dynamic list to list of strings

            int fees = 0;

            // Check if the subjects are available in the fees data for the course
            bool subjectsFound = subjects.every((subject) =>
            allData.containsKey(course) && allData[course].containsKey(subject));

            if (subjectsFound) {
              fees = subjects.fold<int>(0, (total, subject) {
                return total + (allData[course][subject] ?? 0) as int;
              }); // Sum up the fees for all subjects
            } else {
              // If subjects not found, set fees to 0
              fees = 0;
              continue; // Skip to the next user
            }

            // Reference to the user's document under Fees_due collection
            final userDocRef = feesDueDoc.collection('Users').doc(userUid);

            // Save the fees for the user under Fees_due collection if the user does not exist
            await userDocRef.set({
              'Name': '${userData['First Name']} ${userData['Last Name']}', // Store name as a string
              'Course': course, // Store course as a string
              'Subjects': subjects, // Save subjects as list
              'Month': monthYearKey, // Store month as a string
              'UID': userUid, // Store UID as a string
              'Fees': fees, // Store fees as an integer
              'Status': 'Pending', // Store status as a string
            });
          }
        }

        // Show message that fees for this month are already due
        Get.snackbar(
          "Info",
          "Fees for ${monthController.text.trim()} $year already due",
          snackPosition: SnackPosition.BOTTOM,
        );
        return; // Exit function without updating
      }

      // Save all accumulated fees data
      await feesDueDoc.set(allData, SetOptions(merge: true));

      // Fetch all users data from Users collection
      QuerySnapshot usersQuerySnapshot = await FirebaseFirestore.instance.collection('Users').get();

      // Process each user
      for (var userDoc in usersQuerySnapshot.docs) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String userUid = userDoc.id;

        // Check if user is an active student
        if (userData['Status'] == 'Active' && userData['role'] == 'Student') {
          String course = userData['Course'];
          List<String> subjects = (userData['Subject'] as List<dynamic>)
              .map((subject) => subject.toString().trim())
              .toList(); // Convert dynamic list to list of strings

          int fees = 0;

          // Check if the subjects are available in the fees data for the course
          bool subjectsFound = subjects.every((subject) =>
          allData.containsKey(course) && allData[course].containsKey(subject));

          if (subjectsFound) {
            fees = subjects.fold<int>(0, (total, subject) {
              return total + (allData[course][subject] ?? 0) as int;
            }); // Sum up the fees for all subjects
          } else {
            // If subjects not found, set fees to 0
            fees = 0;
            continue; // Skip to the next user
          }

          // Reference to the user's document under Fees_due collection
          final userDocRef = feesDueDoc.collection('Users').doc(userUid);

          // Save the fees for the user under Fees_due collection
          await userDocRef.set({
            'Name': '${userData['First Name']} ${userData['Last Name']}', // Store name as a string
            'Course': course, // Store course as a string
            'Subjects': subjects, // Save subjects as list
            'Month': monthYearKey, // Store month as a string
            'UID': userUid, // Store UID as a string
            'Fees': fees, // Store fees as an integer
            'Status': 'Pending', // Store status as a string
          });
        }
      }

      // Save the month-year key in order in the Fees_due_order collection
      final feesDueOrderDoc = FirebaseFirestore.instance.collection('Fees_due_order').doc('order');
      DocumentSnapshot feesDueOrderSnapshot = await feesDueOrderDoc.get();

      List<String> order = [];
      if (feesDueOrderSnapshot.exists) {
        Map<String, dynamic> data = feesDueOrderSnapshot.data() as Map<String, dynamic>;
        order = List<String>.from(data['order']);
      }
      if (!order.contains(monthYearKey)) {
        order.add(monthYearKey);
        await feesDueOrderDoc.set({'order': order});
      }

      // Show success message
      Get.snackbar(
        "Success",
        "Fees made due for ${monthController.text.trim()} $year",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Show error message
      Get.snackbar(
        "Failed",
        "Unable to due fees. Error: ${e.toString()}",
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
                    if (data['Economics'] != null) Text(
                        'Economics: ₹${data['Economics']}'),
                    if (data['Mathematics'] != null) Text(
                        'Mathematics: ₹${data['Mathematics']}'),
                    if (data['Commerce'] != null) Text(
                        'Commerce: ₹${data['Commerce']}'),
                    if (data['Computer'] != null) Text(
                        'Computer: ₹${data['Computer']}'),
                    if (data['Science'] != null) Text(
                        'Science: ₹${data['Science']}'),
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
