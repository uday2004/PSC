import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../chats/chat page.dart';

class Chats extends StatelessWidget {
  const Chats({super.key});

  // Replace with the specific user ID you want to show
  final String specificUserId = '1lUH4SuuEQgCKb6LKilrCVr8QSw2';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: _buildUserList(),
    );
  }

  // Building a list of users excepting the current user
  Widget _buildUserList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').doc(specificUserId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("User not found"));
        }

        return ListView(
          children: [
            _buildUserListItem(context, snapshot.data!),
          ],
        );
      },
    );
  }

  Widget _buildUserListItem(BuildContext context, DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    String? fname = data['First Name'];
    String? lname = data['Last Name'];

    return ListTile(
      title: Text('$fname $lname'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverUserName: '$fname $lname',
              receiverUserId: document.id,
            ),
          ),
        );
      },
    );
  }
}
