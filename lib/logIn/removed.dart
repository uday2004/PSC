import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Removed extends StatelessWidget {
  const Removed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          children: [
            Icon(Icons.person_remove),
            const SizedBox(height: 20,),
            const Text('Piyush Sir removed you from the class...'),
          ],
        ),
      ),
    );
  }
}
