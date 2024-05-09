import 'package:cloud_firestore/cloud_firestore.dart';

class Message{
  final String senderId;
  final String senderName;
  final String receiverId;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.message,
    required this.timestamp,
});

  Map<String, dynamic>toMap(){
    return{
      'Sender Id': senderId,
      'Sender Name': senderName,
      'Receiver Id': receiverId,
      'Message': message,
      'Timestamp': timestamp,
    };
  }
}