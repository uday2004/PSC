import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Waiting extends StatelessWidget {
  const Waiting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.clock),
            const SizedBox(height: 20,),
            const Text('Please wait until Piyush Sir lets you in...'),
          ],
        ),
      ),
    );
  }
}
