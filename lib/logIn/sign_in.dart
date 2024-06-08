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
  final TextEditingController boardController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();

  bool obscureText = true;
  bool obscureText1 = true;
  String dropdownValue = list.first;
  String dropdownValueBoard = listBoard.first;
  String dropdownValueSubject = listSubject.first;
  final userRepo = Get.put(UserRepository());

  static const List<String> list = <String>['Class 11', 'Class 12', 'CA Foundation'];
  static const List<String> listBoard = <String>['ISC', 'CBSE', 'West Bengal'];
  static const List<String> listSubject = <String>['Mathematics', 'Economics', 'Both(Maths & Economics)'];

  Future<void> createUser(UserModel user) async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      String uid = userCredential.user!.uid;
      CollectionReference ref = FirebaseFirestore.instance.collection('Users');
      await ref.doc(uid).set(user.toJson());
      Navigator.pop(context);
      Get.off(() => const Verification());
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
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
  void dispose() {
    fNameController.dispose();
    lNameController.dispose();
    emailController.dispose();
    classController.dispose();
    passwordController.dispose();
    passwordConformController.dispose();
    boardController.dispose();
    subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 325,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset('assets/images/Piyush_Sharma_Classes_removebg.png', height: 100, width: 100),
                const Text('Welcome!', style: TextStyle(fontSize: 35)),
                const SizedBox(height: 20),
                _buildTextField(fNameController, 'First Name*'),
                const SizedBox(height: 20),
                _buildTextField(lNameController, 'Last Name*'),
                const SizedBox(height: 20),
                _buildTextField(emailController, 'Email ID*'),
                const SizedBox(height: 20),
                _buildDropdownButtonClass(
                  value: dropdownValue,
                  items: list,
                  onChanged: (value) {
                    setState(() {
                      dropdownValue = value;
                      classController.text = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                if (classController.text == 'Class 11' || classController.text == 'Class 12') ...[
                  const SizedBox(height: 20),
                  _buildDropdownButtonBoard(
                    value: dropdownValueBoard,
                    items: listBoard,
                    onChanged: (value) {
                      setState(() {
                        dropdownValueBoard = value;
                        boardController.text = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildDropdownButtonSubject(
                    value: dropdownValueSubject,
                    items: listSubject,
                    onChanged: (value) {
                      setState(() {
                        dropdownValueSubject = value;
                        subjectController.text = value;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 20),
                _buildPasswordField(passwordController, 'Password*', obscureText, () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                }),
                const SizedBox(height: 20),
                _buildPasswordField(passwordConformController, 'Confirm Password*', obscureText1, () {
                  setState(() {
                    obscureText1 = !obscureText1;
                  });
                }),
                const SizedBox(height: 20),
                const Text('Enter a 6 digit password'),
                const SizedBox(height: 20),
                const Text('By signing up, you agree to our '),
                _buildLink('Privacy Policy', 'https://www.termsfeed.com/live/3eef2486-0da1-4713-9026-6662497c894f'),
                _buildLink('Terms & Conditions', 'https://www.termsfeed.com/live/c904f853-ed51-4981-a266-20e82ea92123'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signUp,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                  ),
                  child: const Text('Accept and Continue'),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return const LogIn();
                        }));
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: Colors.blueAccent,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 35),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
    );
  }

  Widget _buildDropdownButtonClass({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButton<String>(
      isExpanded: true,
      value: value,
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
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildDropdownButtonSubject({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButton<String>(
      isExpanded: true,
      value: value,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      underline: Container(
        height: 2,
        color: Colors.orangeAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValueSubject = value!;
          subjectController.text = value;
        });
      },
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildDropdownButtonBoard({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButton<String>(
      isExpanded: true,
      value: value,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      underline: Container(
        height: 2,
        color: Colors.orangeAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValueBoard = value!;
          boardController.text = value;
        });
      },
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller, String hintText, bool obscureText, VoidCallback toggleVisibility) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: IconButton(
          onPressed: toggleVisibility,
          icon: Icon(obscureText ? CupertinoIcons.eye : CupertinoIcons.eye_slash),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
    );
  }

  Widget _buildLink(String text, String url) {
    return Link(
      target: LinkTarget.self,
      uri: Uri.parse(url),
      builder: (context, followLink) => TextButton(
        onPressed: followLink,
        child: Text(
          text,
          style: const TextStyle(color: Colors.blueAccent),
        ),
      ),
    );
  }

  void _signUp() {
    if (fNameController.text.isEmpty ||
        lNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        classController.text.isEmpty ||
        passwordController.text.isEmpty ||
        passwordConformController.text.isEmpty) {
      _showErrorDialog('Please enter all required information.');
    } else if (passwordController.text != passwordConformController.text) {
      _showErrorDialog('Passwords do not match.');
    } else {
      final user = UserModel(
        fName: fNameController.text.trim(),
        lName: lNameController.text.trim(),
        password: passwordController.text.trim(),
        emailID: emailController.text.trim(),
        course: classController.text.trim(),
        status: '',
        board: boardController.text.trim(),
        subject: subjectController.text.trim(),
      );
      createUser(user);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
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
