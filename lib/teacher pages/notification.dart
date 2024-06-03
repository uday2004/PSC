import 'package:flutter/material.dart';

class NotificationPiyush extends StatefulWidget {
  const NotificationPiyush({super.key});

  @override
  State<NotificationPiyush> createState() => _NotificationPiyushState();
}

class _NotificationPiyushState extends State<NotificationPiyush> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification"),
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
    );
  }
}
