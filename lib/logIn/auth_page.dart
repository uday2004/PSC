import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:psc/logIn/removed.dart';
import 'package:psc/logIn/waiting.dart';

import '../student pages/home_page.dart';
import '../teacher pages/home.dart';
import 'log_in.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            // User is authenticated, check their role
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(snapshot.data!.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Return a loading indicator while waiting for the document snapshot
                  return const  Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  // Document snapshot is available, check user's role
                  String role = snapshot.data!['role'];
                  String status = snapshot.data!['Status'];
                  if (role == 'Teacher' && status=='Active') {
                    // Navigate to teacher page
                    return const Piyush_Home();
                  } else {
                    // Navigate to student page
                    if(status == 'Active'){
                      return const HomePage();
                    }else if (status == 'Waiting'){
                      return const Waiting();
                    }else{
                      return const Removed();
                    }
                  }
                } else {
                  // Document snapshot not available, handle error
                  return const Text('Error: Document does not exist');
                }
              },
            );
          } else {
            // User is not authenticated, navigate to login page
            return const LogIn();
          }
        },
      ),
    );
  }
}
