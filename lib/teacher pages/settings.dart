import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logIn/log_in.dart';
import '../theme/theme.dart';
import '../theme/theme_provider.dart';

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
          return Column(
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
              const SizedBox(
                width: 375,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    suffixIcon: Icon(CupertinoIcons.pen),
                  ),

                ),
              ),
              const SizedBox(height: 20,),
              const SizedBox(
                width: 375,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: Icon(CupertinoIcons.pen),
                  ),

                ),
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
          );
        },
      ),
    );
  }
}
