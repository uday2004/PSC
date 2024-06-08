import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FeesList extends StatefulWidget {
  final String month;

  const FeesList({required this.month, super.key});

  @override
  State<FeesList> createState() => _FeesListState();
}

class _FeesListState extends State<FeesList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees Details'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Fees_due')
            .doc(widget.month)
            .collection('Users')
            .snapshots(),
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

          final usersDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: usersDocs.length,
            itemBuilder: (context, index) {
              final userDoc = usersDocs[index];
              final userData = userDoc.data() as Map<String, dynamic>;
              final name = userData['Name'] ?? 'No Name';
              final status = userData['Status'] ?? 'No Status';
              final month = userData['Month'] ?? 'No Status';
              final uid = userData['UID'] ?? 'No Status';
              final courseSubject = '${userData['Course']} ${userData['Subject']}';

              return ListTile(
                title: Text('$name $courseSubject'),
                subtitle: Text('Status: $status'),
                trailing: checkStatus(status,uid, month),
              );
            },
          );
        },
      ),
    );
  }

  Widget checkStatus(String status, String userId, String month) {
    switch (status) {
      case 'Paid':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'Pending':
        return IconButton(
          onPressed: () async {
            // Perform the desired action when the button is pressed
            // Update the user status to 'Paid'
            await FirebaseFirestore.instance
                .collection('Fees_due')
                .doc(month)
                .collection('Users')
                .doc(userId)
                .update({'Status': 'Paid'});
          },
          icon: const Icon(Icons.check),
        );
      case 'Waiting':
        return IconButton(
          onPressed: () async {
            // Perform the desired action when the button is pressed
            // Update the user status to 'Paid'
            await FirebaseFirestore.instance
                .collection('Fees_due')
                .doc(month)
                .collection('Users')
                .doc(userId)
                .update({'Status': 'Paid'});
          },
          icon: const Icon(Icons.check),
        );
      default:
        return const Icon(Icons.help, color: Colors.grey);
    }
  }
}
