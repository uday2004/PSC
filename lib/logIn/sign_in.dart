import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import '../repository/user_repository.dart';
import 'log_in.dart';
import 'verification.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

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
  String dropdownValue = '';
  String dropdownValueBoard = '';
  final userRepo = Get.put(UserRepository());

  List<String> classlist = [];
  List<String> subjectlist = [];
  List<String> dropdownValueSubject = [];

  @override
  void initState() {
    super.initState();
    fetchClassList();
  }

  Future<void> fetchClassList() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Course').get();
      setState(() {
        classlist = querySnapshot.docs.map((doc) => doc.id).toList();
        if (classlist.isNotEmpty) {
          dropdownValue = classlist.first;
          classController.text = dropdownValue;
          fetchSubjectList(dropdownValue);
        }
      });
    } catch (e) {
      print('Error fetching class list: $e');
    }
  }

  Future<void> fetchSubjectList(String selectedClass) async {
    try {
      DocumentSnapshot docSnapshot =
      await FirebaseFirestore.instance.collection('Course').doc(selectedClass).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        List<dynamic> subjectData = docSnapshot['Subject'];
        setState(() {
          subjectlist = subjectData.map((subject) => subject.toString()).toList();
        });
      } else {
        setState(() {
          subjectlist = [];
        });
      }
    } catch (e) {
      print('Error fetching subject list: $e');
    }
  }

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
            content: Text(e.message ?? 'An error occurred.'),
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
    super.dispose();
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
      value: value.isNotEmpty ? value : null,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      underline: Container(
        height: 2,
        color: Colors.orangeAccent,
      ),
      onChanged: (String? value) {
        onChanged(value!);
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
      value: value.isNotEmpty ? value : null,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      underline: Container(
        height: 2,
        color: Colors.orangeAccent,
      ),
      onChanged: (String? value) {
        onChanged(value!);
      },
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildSubjectSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Subjects', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          children: subjectlist.map((subject) {
            bool isSelected = dropdownValueSubject.contains(subject);

            return Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value ?? false) {
                        dropdownValueSubject.add(subject); // Add subject if checked
                      } else {
                        dropdownValueSubject.remove(subject); // Remove subject if unchecked
                      }
                    });
                  },
                ),
                Text(subject),
              ],
            );
          }).toList(),
        ),
      ],
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
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
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
    return InkWell(
      onTap: () {
        // Add link handling here, such as launching a URL
      },
      child: Text(
        text,
        style: const TextStyle(color: Colors.blueAccent),
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
    } else if (dropdownValueSubject.isEmpty) {
      _showErrorDialog('Please select at least one subject.');
    } else {
      final user = UserModel(
        fName: fNameController.text.trim(),
        lName: lNameController.text.trim(),
        password: passwordController.text.trim(),
        emailID: emailController.text.trim(),
        course: classController.text.trim(),
        status: '',
        board: boardController.text.trim(),
        subject: dropdownValueSubject, // Use dropdownValueSubject as List<String>
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
    items: classlist.isNotEmpty ? classlist : [],
    onChanged: (value) {
    setState(() {
      dropdownValue = value;
      classController.text = value;
      fetchSubjectList(value);
    });
    },
    ),
      const SizedBox(height: 20),
      if (dropdownValue.startsWith('Class')) ...[
        _buildDropdownButtonBoard(
          value: dropdownValueBoard,
          items: ['ISC', 'CBSE', 'West Bengal'],
          onChanged: (value) {
            setState(() {
              dropdownValueBoard = value;
              boardController.text = value;
            });
          },
        ),
      ],
      const SizedBox(height: 20),
      _buildSubjectSelection(),
      const SizedBox(height: 20),
      _buildPasswordField(passwordController, 'Password*', true, () {}),
      const SizedBox(height: 20),
      _buildPasswordField(passwordConformController, 'Confirm Password*', true, () {}),
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
}
