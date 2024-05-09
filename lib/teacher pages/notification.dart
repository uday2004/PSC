import 'package:flutter/material.dart';

class Piyush_Notification extends StatelessWidget {
  const Piyush_Notification({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Notification'),
      ),

    );
  }
}
