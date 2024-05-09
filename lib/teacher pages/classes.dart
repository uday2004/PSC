import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Piyush_Classes extends StatelessWidget {
  const Piyush_Classes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
                onPressed: (){
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context){
                        return const MeetingOption();
                      }
                  );
                },
                child: const Icon(Icons.add_call)
            ),
          ),
        ],
      ),
    );
  }
}

class MeetingOption extends StatefulWidget {
  const MeetingOption({super.key});

  @override
  State<MeetingOption> createState() => _MeetingOptionState();
}

class _MeetingOptionState extends State<MeetingOption> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(CupertinoIcons.xmark),
        ),
        title: const Text('Create Meeting'),
      ),
      body: Column(
        children: [
          const Divider(),
          TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Row(
                children: [
                  Icon(
                    Icons.electric_bolt,
                    color: Colors.black,
                  ),
                  SizedBox(width: 25,),
                  Text(
                    'Create a instant meeting',
                    style: TextStyle(
                        fontSize: 23,
                        color: Colors.black
                    ),
                  )
                ],
              ),
          ),
          const SizedBox(height: 10,),
          TextButton(
            onPressed: (){},
            child: const Row(
              children: [
                Icon(
                  CupertinoIcons.calendar_badge_plus,
                  color: Colors.black,
                ),
                SizedBox(width: 25,),
                Text(
                  'Schedule a meeting',
                  style: TextStyle(
                      fontSize: 23,
                      color: Colors.black
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

