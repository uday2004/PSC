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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: currentUser == null
          ? const Center(child: Text('User not logged in'))
          : Column(
        children: [
          Expanded(child: _buildOtherMonthsFees(currentUser.uid)),
        ],
      ),
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
          selectedTileColor: Theme.of(context).colorScheme.secondary,
          title: Text("Month: $title "),
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

  Widget checkStatus(String status, String userId, String month) {
    TextEditingController modeController = TextEditingController();
    List<String> mode = ['Cash', 'Online'];
    String dropdownValue = mode.first;

    switch (status) {
      case 'Paid':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'Pending':
        return IconButton(
          onPressed: () async {
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
