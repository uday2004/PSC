import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/mail verification.dart';
import '../student pages/home_page.dart';

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  String? email;
  final otpController = Get.put(MailVerificationController());

  @override
  void initState() {
    super.initState();
    // Get the current user's email when the screen initializes
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        email = user.email;
      });
    }
  }

  void verify(){
    Navigator.push(context,
      MaterialPageRoute(builder: (context){
        return HomePage();
      })
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Container(
          width: 350,
          height: 350,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                width: 100, 
                height: 100,
                child: Image.asset('assets/images/Piyush_Sharma_Classes_removebg.png'),
              ),
              const SizedBox(height: 40,),
              const Text('Verification code sent to your registered email ID:'),
              const SizedBox(height: 10),
              Text(
                email ?? 'Loading...', // Show 'Loading...' if email is null
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20,),
              ElevatedButton(
                  onPressed: (){
                    verify();
                  },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                ),
                  child: const Text('Continue',style: TextStyle(color: Colors.black),),
              ),
            ],
          )
        )
      ),
    );
  }
}
