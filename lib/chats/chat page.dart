import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'chat services.dart';


class ChatPage extends StatefulWidget {

  final String receiverUserName;
  final String receiverUserId;

  const ChatPage({
    super.key,
    required this.receiverUserName,
    required this.receiverUserId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage()async{
    //only send the message if there is any
    if(_messageController.text.isNotEmpty){
      await ChatService().sendMessage(
          widget.receiverUserId,
          _messageController.text,
      );
      _messageController.clear();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(widget.receiverUserName),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          //messages
          Expanded(
              child: _buildMessagelist(),
          ),
          //user input
          _buidmessageInput(),
        ],
      ),
    );
  }

  //build message list
  Widget _buildMessagelist(){
    return StreamBuilder(
        stream: ChatService().getMessages(
          widget.receiverUserId, _firebaseAuth.currentUser!.uid,
        ),
        builder: (context, snapshot) {
          if(snapshot.hasError){
            return Text('error${snapshot.error}');
          }
          if(snapshot.connectionState ==ConnectionState.waiting){
            return const Text('loadind...');
          }

          return ListView(
            children: snapshot.data!.docs
                .map((document) => _buildMessageItem(document))
                .toList(),
          );
        },
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    //align the message
    var alignment = (data['Sender Id']==_firebaseAuth.currentUser!.uid)
        ?Alignment.centerRight
        :Alignment.centerLeft;

   return Padding(
     padding: const EdgeInsets.all(8),
     child: Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment: (data['Sender Id']==_firebaseAuth.currentUser!.uid)
              ?CrossAxisAlignment.end
              :CrossAxisAlignment.start,
          children: [
            Text(data['Sender Name'],),
            Text(data['Message'])
          ],
        ),
      ),
   );
  }

  //build message input
  Widget _buidmessageInput(){
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          //text feild
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Enter Message',
              ),
              obscureText: false,
            ),
          ),

          //send button
          IconButton(
              onPressed: sendMessage,
              icon: const Icon(CupertinoIcons.up_arrow))
        ],
      ),
    );
  }
}
