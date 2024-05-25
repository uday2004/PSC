import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../chats/chat page.dart';

class Piyush_Chats extends StatelessWidget {
  const Piyush_Chats({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: _buildUserList(),
    );
  }

  //building a list of users excepting the current user
  Widget _buildUserList (){
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').where('Status', isEqualTo: 'Active').snapshots(),
      builder: (context, snapshot){
        if(snapshot.hasError){
          return const Text("error");
        }

        if(snapshot.connectionState == ConnectionState.waiting){
          return const Text("loading...");
        }
        
        return ListView(
          children: snapshot.data!.docs
              .where((doc) =>
          doc.id != FirebaseAuth.instance.currentUser!.uid)
              .map<Widget>((doc) => _buildUserListItem(context, doc))
              .toList(),
        );
      },
    );
  }

  //
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