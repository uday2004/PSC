import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalInfo extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String userId;

  const PersonalInfo({Key? key, required this.userData, required this.userId}) : super(key: key);

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _courseController;
  late TextEditingController _emailController;
  String _selectedClass = '';
  String _selectedBoard = '';
  String _selectedSubject = '';

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.userData['First Name']);
    _lastNameController = TextEditingController(text: widget.userData['Last Name']);
    _courseController = TextEditingController(text: widget.userData['Course']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _selectedClass = widget.userData['Class'] ?? '';
    _selectedSubject = widget.userData['Subject'] ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _courseController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('Users').doc(widget.userId).update({
          'First Name': _firstNameController.text,
          'Last Name': _lastNameController.text,
          'Course': _courseController.text,
          'email': _emailController.text,
          'Class': _selectedClass,
          'Board': _selectedBoard,
          'Subject': _selectedSubject,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user data: $e')),
        );
      }
    }
  }

  Future<void> _showSelectionDialog(String title, List<String> options, void Function(String) onSelect) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: DropdownButtonFormField<String>(
            value: options.contains(_selectedBoard) ? _selectedBoard : null,
            onChanged: (value) {
              onSelect(value!);
              Navigator.of(context).pop();
            },
            items: options
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Information'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  // Add email validation
                  if (!value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text('Course: ${_courseController.text}'),
                onTap: () {
                  _showSelectionDialog('Select Course', ['Class 11', 'Class 12', 'CA Foundation'], (value) {
                    setState(() {
                      _courseController.text = value;
                      if (value == 'CA Foundation') {
                        _selectedClass = 'CA Foundation';
                        _selectedBoard = '';
                        _selectedSubject = '';
                      }
                    });
                  });
                },
              ),
              const Divider(),
              ListTile(
                title: Text('Board: $_selectedBoard'),
                onTap: () {
                  _showSelectionDialog('Select Board', ['ISC', 'CBSE', 'West Bengal'], (value) {
                    setState(() {
                      _selectedBoard = value;
                    });
                  });
                },
              ),
              const Divider(),
              ListTile(
                title: Text('Subject: $_selectedSubject'),
                onTap: () {
                  _showSelectionDialog('Select Subject', ['Mathematics', 'Economics', 'Both(Maths & Economics)'], (value) {
                    setState(() {
                      _selectedSubject = value;
                    });
                  });
                },
              ),
              const Divider(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUserData,
                child: const Text('Update', style: TextStyle(color: Colors.orangeAccent),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
