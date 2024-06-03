import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psc/teacher%20pages/personal%20info.dart';

class RemovedStudents extends StatefulWidget {
  const RemovedStudents({super.key});

  @override
  State<RemovedStudents> createState() => _RemovedStudentsState();
}

class _RemovedStudentsState extends State<RemovedStudents> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Removed Student'),
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final students = snapshot.data?.docs ?? [];
            final activeStudents = students.where((user) {
              final data = user.data() as Map<String, dynamic>;
              final status = data['Status'] as String?;
              final role = data['role'] as String?;
              return status == 'Removed' && role == 'Student';
            }).toList();

            if (activeStudents.isEmpty) {
              return const Center(child: Text('No one is removed'));
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: activeStudents.length,
              itemBuilder: (context, index) {
                final user = activeStudents[index].data() as Map<String, dynamic>?;
                if (user != null) {
                  final firstName = user['First Name'] as String?;
                  final lastName = user['Last Name'] as String?;
                  final course = user['Course'] as String?;
                  final email = user['email'] as String?;
                  final name = '${firstName ?? ''} ${lastName ?? ''} (${course ?? ''})';

                  return ListTile(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const PersonalInfo();
                      }));
                    },
                    title: Text(name),
                    subtitle: Text(email ?? ''),
                    trailing: IconButton(
                      onPressed: () async {
                        try {
                          await FirebaseFirestore.instance.collection('Users')
                              .doc(activeStudents[index].id) // Use the document ID directly
                              .update({'Status': 'Active'});
                        } catch (e) {
                          print('Error updating document: $e');
                        }
                      },
                      icon: const Icon(Icons.check),
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              },
            );
          }
        },
      ),
    );
  }
}
