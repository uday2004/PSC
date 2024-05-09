import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:psc/logIn/sign_in.dart';

import 'auth_page.dart';
import 'forgotPassword.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {


  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscureText = true;


  void toggleObscureText() {
    setState(() {
      obscureText = !obscureText;
    });
  }


  void logIn() async {
    const CircularProgressIndicator();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userNameController.text,
        password: passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Handle login errors
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('$e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Center(
        child: SizedBox(
          width: 325,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Image.asset('assets/images/Piyush_Sharma_Classes_removebg.png'),
                  ),
                  const Text('Welcome Back!',style: TextStyle(fontSize: 34),),
                  const SizedBox(height: 20,),
                  TextField(
                    controller: userNameController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                    suffix: const Icon(Icons.supervised_user_circle_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                            color: Colors.orange
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  TextField(
                    obscureText: obscureText,
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: 'Password',
                    suffix: IconButton(
                      onPressed: (){
                      toggleObscureText();
                      },
                      icon: const Icon(CupertinoIcons.eye_slash),
                    ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                            color: Colors.orange
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const ForgetPassword();
                      }));
                    },
                    child: const Text('Forgot Password?',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  ElevatedButton(onPressed: logIn,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                    ),
                    child: const Text('Log in',
                  style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10,),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Do not have an account ?'),
                      TextButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return const SignIn();
                            }));
                          },
                          child: const Text('Sign up now',
                          style: TextStyle(color: Colors.blueAccent),
                          ),
                      ),
                    ],
                  ),
                ]
              ),
          ),
          ),
        ),
    );
  }
}