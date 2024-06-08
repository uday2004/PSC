import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logIn/log_in.dart';
import '../theme/theme.dart';
import '../theme/theme_provider.dart';

class PSCSettings extends StatefulWidget {
  const PSCSettings({super.key});

  @override
  State<PSCSettings> createState() => _PSCSettingsState();
}

class _PSCSettingsState extends State<PSCSettings> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Settings',
        ),
      ),
      body:  Column(
        children: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('Users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return const Text('No data available');
              }

              final documents = snapshot.data!.docs;
              final currentUID = FirebaseAuth.instance.currentUser?.uid;

              // Find the document with the current user's UID
              final userData = documents.firstWhere(
                    (doc) => doc.id == currentUID,
              );

              // Retrieve the first name and last name if the user's document exists
              final firstName = userData['First Name'] as String?;
              final lastName = userData['Last Name'] as String?;
              final course = userData['Course'] as String?;
              final board = userData['Board'] as String?;
              final email= userData['email'] as String?;
              final sub = userData['Subject'] as String?;
              final fullName = '$firstName $lastName';

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10,),
                  Text("Name: $fullName", style: const TextStyle(fontSize: 18),),
                  const SizedBox(height: 10,),
                  Text("Course: $course", style: const TextStyle(fontSize: 18),),
                  const SizedBox(height: 10,),
                  Text("Board: $board", style: const TextStyle(fontSize: 18),),
                  const SizedBox(height: 10,),
                  Text("Email: $email", style: const TextStyle(fontSize: 18),),
                  const SizedBox(height: 10,),
                  Text("Subject: $sub", style: const TextStyle(fontSize: 18),),
                  const SizedBox(height: 10,),
                ],
              );
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                            'Theme',
                          style: TextStyle(
                            fontSize: 18
                          ),
                        ),
                        Switch(
                          value: themeProvider.themeData == darkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20,),
                    TextButton(onPressed: () async {
                      try {
                        // Sign the user out
                        await FirebaseAuth.instance.signOut();
                        // Navigate back to the sign-in/log-in screen
                        Navigator.pushReplacement(
                        context,
                          MaterialPageRoute(builder: (context) => const LogIn()),
                        );
                      } catch (e) {
                        // Handle sign-out errors
                        if (kDebugMode) {
                          print('Error signing out: $e');
                        }
                      }
                    },
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all<Color>(Colors.red),
                          backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.secondary),
                          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.all(10)),
                        ),
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}