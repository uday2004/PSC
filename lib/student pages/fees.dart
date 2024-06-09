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
          _buildCurrentMonthFees(currentUser.uid, currentMonthYear),
          Expanded(child: _buildOtherMonthsFees(currentUser.uid)),
        ],
      ),
    );
  }

  // Helper function to build the current month's fees stream
  Widget _buildCurrentMonthFees(String uid, String currentMonthYear) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Fees_due')
          .doc(currentMonthYear)
          .collection('Users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading fees'));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text(' '));
        }

        var doc = snapshot.data!;
        String title = doc['Month'];
        String status = doc['Status'];

        return ListTile(
          title: Text("Month: $title "),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(status),
              const Divider(),
            ],
          ),
          trailing: checkStatus(status, uid, currentMonthYear),
        );
      },
    );
  }

  // Helper function to build the other months' fees stream
  Widget _buildOtherMonthsFees(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Fees_due').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading fees'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text(' '));
        }

        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
        List<Widget> userFees = [];

        for (var doc in docs) {
          userFees.add(
            _buildUserFee(doc.reference.collection('Users').doc(uid)),
          );
        }

        return ListView(
          shrinkWrap: true,
          children: userFees.isEmpty
              ? [const Center(child: Text(' '))]
              : userFees,
        );
      },
    );
  }

  // Helper function to build each user's fee information
  Widget _buildUserFee(DocumentReference userDocRef) {
    return StreamBuilder<DocumentSnapshot>(
      stream: userDocRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading fees'));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        var userDoc = snapshot.data!;
        String title = userDoc['Month'];
        String status = userDoc['Status'];
        int fees = userDoc['Fees'];

        return ListTile(
          title: Text("Month: $title"),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$status ₹ $fees'),
              const Divider(),
            ],
          ),
          trailing: checkStatus(status, userDocRef.id, title),
        );
      },
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

  Widget checkStatus(String status, String userId, String month) {
    switch (status) {
      case 'Paid':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'Pending':
        return IconButton(
          onPressed: () async {
            // Update the user status to 'Waiting'
            await FirebaseFirestore.instance
                .collection('Fees_due')
                .doc(month)
                .collection('Users')
                .doc(userId)
                .update({'Status': 'Waiting'});
          },
          icon: const Icon(Icons.check),
        );
      case 'Waiting':
        return const Icon(Icons.error_outlined, color: Colors.red);
      default:
        return const Icon(Icons.help, color: Colors.grey);
    }
  }
}
