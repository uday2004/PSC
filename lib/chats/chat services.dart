import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../models/chat_model.dart';

class ChatService extends ChangeNotifier {
  // Instance of Firebase Authentication
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String currentUserName = "";
  // Send message
  Future<void> sendMessage(String receiverId, String message) async {
    // Get current user ID
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    // Retrieve receiver's information from Firestore
    DocumentSnapshot receiverSnapshot =
    await _firebaseFirestore.collection('Users').doc(currentUserId).get();

    // Check if the document exists
    if (receiverSnapshot.exists) {
      // Get the data of the receiver
      Map<String, dynamic> data = receiverSnapshot.data() as Map<String, dynamic>;
      String? fname = data['First Name'];
      String? lname = data['Last Name'];

      // Construct the current user's name
      currentUserName = '$fname $lname';
    }
      // Construct message data
        final String CurrentUserId = currentUserId;
        final String CurrentUserName = currentUserName;
        final Timestamp timestamp = Timestamp.now();

      // create new message
      Message newMessage = Message(
        senderId: CurrentUserId,
        senderName: CurrentUserName,
        receiverId: receiverId,
        message: message,
        timestamp: timestamp,
      );
      //get the chat room ids
      List<String> ids = [CurrentUserId, receiverId];
      ids.sort();//sort the ids
      String chatRoomId = ids.join("_");//combine the ids to create the chat room ids

      //add the new message to the database
      await _firebaseFirestore.collection('chat_room')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());
  }

  // Get message
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId){
    //construct chat room id
    List<String> ids = [userId,otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firebaseFirestore.collection('chat_room')
        .doc(chatRoomId)
        .collection('message')
        .orderBy('_timestamp', descending: false)
        .snapshots();
  }
}
