import 'package:flutter/material.dart';

class TestMode extends StatefulWidget {
  const TestMode({super.key});

  @override
  State<TestMode> createState() => _TestModeState();
}

class _TestModeState extends State<TestMode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Mode'),
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
