import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Fees extends StatefulWidget {
  const Fees({super.key});

  @override
  State<Fees> createState() => _FeesState();
}

class _FeesState extends State<Fees> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Get the current month and year as a string (e.g., "March_2024")
    final now = DateTime.now();
    final currentMonthYear = '${_getMonthText(now.month)}_${now.year}';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: currentUser == null
          ? const Center(child: Text('User not logged in'))
          : Column(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Fees_due')
                .doc(currentMonthYear)
                .collection('Users')
                .doc(currentUser.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading links'));
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('No Fees found for the current month'));
              }

              var doc = snapshot.data!;
              String title = doc['Month'];
              String course = doc['Course'];
              String sub = doc['Subject'];
              String status = doc['Status'];

              return ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: Text("Month: $title $sub $course"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(status),
                        const Divider(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Fees_due')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading links'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text(' '));
                }

                List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
                List<Widget> userFees = [];

                for (var doc in docs) {
                  if (doc.reference.collection('Users').doc(currentUser.uid) != null) {
                    userFees.add(
                      StreamBuilder<DocumentSnapshot>(
                        stream: doc.reference.collection('Users').doc(currentUser.uid).snapshots(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (userSnapshot.hasError) {
                            return const Center(child: Text('Error loading links'));
                          }
                          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                            return const SizedBox.shrink();
                          }

                          var userDoc = userSnapshot.data!;
                          String title = userDoc['Month'];
                          String status = userDoc['Status'];
                          String sub = userDoc['Subject'];
                          String course = userDoc['Course'];
                          String fees = userDoc['Fees'];
                          return ListTile(
                            title: Text("Topic: $title $sub $course"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$status ₹ $fees'),
                                const Divider(),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }
                }

                return ListView(
                  shrinkWrap: true,
                  children: userFees.isEmpty
                      ? [const Center(child: Text('No Fees found for other months'))]
                      : userFees,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to get the month as a text string
  String _getMonthText(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
