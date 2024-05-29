import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:psc/logIn/verification.dart';
import 'package:url_launcher/link.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import '../repository/user_repository.dart';
import 'log_in.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConformController = TextEditingController();
  bool obscureText = true;
  bool obscureText1 = true;
  String dropdownValue = list.first;
  final userRepo = Get.put(UserRepository());

  static const List<String> list = <String>['Class 11', 'Class 12', 'CA Foundation'];

  void toggleObscureText() {

  }

  Future<void> createUser (UserModel user) async {
    showDialog(context: context,
        builder: (context){
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
    );

    try {
      //Create a new user using email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      String uid = userCredential.user!.uid;
      CollectionReference ref = FirebaseFirestore.instance.collection('Users');
      await ref.doc(uid).set(user.toJson());
      // Dismiss the loading indicator dialog
      Navigator.pop(context);

      // Navigate to the home page
      Get.off(() => const Verification());
    } on FirebaseAuthException catch(e){
      // Handle FirebaseAuthException
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
      // Dismiss the loading indicator dialog
      Navigator.pop(context);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: SizedBox(
            width: 325,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20,),
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.asset('assets/images/Piyush_Sharma_Classes_removebg.png'),
                ),
                const Text('Welcome!',style: TextStyle(fontSize: 35),),
                const SizedBox(height: 20,),
                TextField(
                  controller: fNameController,
                  decoration: InputDecoration(
                    hintText: 'First Name*',
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
                  controller: lNameController,
                  decoration: InputDecoration(
                    hintText: 'Last Name*',
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
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email ID*',
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
                DropdownButton<String>(
                  isExpanded: true,
                icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  underline: Container(
                    height: 2,
                    color: Colors.orangeAccent,
                  ),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      dropdownValue = value!;
                      classController.text = value;
                    });
                  },
                  items: list.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  value: dropdownValue,
                ),
                const SizedBox(height: 20,),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password*',
                    suffix: IconButton(
                      onPressed: (){
                        setState(() {
                          obscureText = !obscureText;
                        });
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
                const SizedBox(height: 20,),
                TextField(
                  controller: passwordConformController,
                  decoration: InputDecoration(
                    hintText: 'Conform Password*',
                    suffix: IconButton(
                      onPressed: (){
                        setState(() {
                          obscureText1 = !obscureText;
                        });
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
                const SizedBox(height: 20,),
                const Text('Enter a 6 digit password'),
                const SizedBox(height: 20,),
                const Text('By signing up, you agree to our '),
                Link(
                  target: LinkTarget.self,
                    uri: Uri.parse('https://www.termsfeed.com/live/3eef2486-0da1-4713-9026-6662497c894f'),
                    builder: (context, followlink) => TextButton(
                        onPressed: followlink,
                        child: const Text('Privacy Policy',style: TextStyle(color: Colors.blueAccent),),
                    )
                ),
                Link(
                    target: LinkTarget.self,
                    uri: Uri.parse('https://www.termsfeed.com/live/c904f853-ed51-4981-a266-20e82ea92123'),
                    builder: (context, follow_link) => TextButton(
                      onPressed: follow_link,
                      child: const Text('Terms & Conditions',style: TextStyle(color: Colors.blueAccent),),
                    )
                ),

                const SizedBox(height: 20,),
                ElevatedButton(
                  onPressed: () {
                      if (fNameController.text.isEmpty ||
                          lNameController.text.isEmpty ||
                          emailController.text.isEmpty ||
                          classController.text.isEmpty ||
                          passwordController.text.isEmpty ||
                          passwordConformController.text.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: const Text('Please enter all required information.'),
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
                      } else {
                        final user = UserModel(
                          fName: fNameController.text.trim(),
                          lName: lNameController.text.trim(),
                          password: passwordController.text.trim(),
                          emailID: emailController.text.trim(),
                          course: classController.text.trim(),
                          status: '',
                          groupId: [],
                        );
                        createUser(user);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                  ),
                  child: const Text('Accept and Continue'),
                ),

                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an acccount ?'),
                    TextButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const LogIn();
                      }));
                    },
                      child: const Text('Log In',
                        style: TextStyle(
                          color: Colors.blueAccent,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 35,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
