import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psc/teacher%20pages/change%20fees.dart';
import 'package:psc/teacher%20pages/removed%20student.dart';

import '../logIn/log_in.dart';
import '../theme/theme.dart';
import '../theme/theme_provider.dart';
import 'course.dart';

class Piyush_Settings extends StatelessWidget {
  const Piyush_Settings({super.key});

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
      body:  Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const RemovedStudents();
                      }));
                    },
                    child:const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Removed Student",textAlign: TextAlign.left,style: TextStyle(color: Colors.black,fontSize: 18),),
                        Icon(Icons.arrow_forward_ios,color: Colors.black,),
                      ],
                    )
                ),
                TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const Course();
                      }));
                    },
                    child:const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Course",textAlign: TextAlign.left,style: TextStyle(color: Colors.black,fontSize: 18),),
                        Icon(Icons.arrow_forward_ios,color: Colors.black,),
                      ],
                    )
                ),
                TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const ChangeFees();
                      }));
                    },
                    child:const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Fees",textAlign: TextAlign.left,style: TextStyle(color: Colors.black,fontSize: 18),),
                        Icon(Icons.arrow_forward_ios,color: Colors.black,),
                      ],
                    )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Theme',
                      style: TextStyle(
                          color: Colors.black,
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
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                    backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.secondary),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.all(10)),
                  ),
                  child: const Text('Log Out'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
