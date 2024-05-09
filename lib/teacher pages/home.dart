import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:psc/teacher%20pages/settings.dart';
import 'package:psc/teacher%20pages/study_material.dart';
import 'notification.dart'as my_app_notification;
import 'assignment.dart';
import 'chats.dart';
import 'classes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Piyush_Home extends StatefulWidget {
  const Piyush_Home({super.key});

  @override
  State<Piyush_Home> createState() => _Piyush_HomeState();
}

class _Piyush_HomeState extends State<Piyush_Home> {
  late PageController _pageController;
  int _currentIndex = 0;
  int choiceIndex = 0;

  Future<void> _refresh(){
    return Future.delayed(const Duration (seconds: 0),);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustAppBar(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          // Your pages here
          HomePageContent(context),
          Piyush_Assignment(),
          Piyush_Classes(),
          Piyush_Chats(),
          Piyush_Study_Material(),
        ],
      ),
      bottomNavigationBar: CustBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          });
        },
      ),
    );
  }

  Container HomePageContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20,),
                const Text('Students in waiting room',style: TextStyle(fontSize: 20),),
                const SizedBox(height: 20,),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('Users').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final students = snapshot.data?.docs ?? [];
                        if (students.contains('Status') != 'Waiting') {
                          return const Text('No one is in the waiting room...');
                        } else {
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final user = students[index].data();
                              if (user != null &&
                                  user is Map<String, dynamic>) {
                                final status = user['Status'] as String?; // Nullable
                                final firstName = user['First Name'] as String?;
                                final lastName = user['Last Name'] as String?;
                                final course = user['Course'] as String?;
                                if (status?.toLowerCase() == 'waiting') {
                                  final name = (firstName ?? '') + ' ' +
                                      (lastName ?? '');
                                  return ListTile(
                                    title: Text(name),
                                    subtitle: Text(course ?? ''),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                            onPressed: () async {
                                              try {
                                                await FirebaseFirestore.instance
                                                    .collection('Users')
                                                    .doc(students[index]
                                                    .id) // Use the document ID directly
                                                    .update(
                                                    {'Status': 'Active'});
                                                print(
                                                    'Document updated successfully');
                                              } catch (error) {
                                                print(
                                                    'Error updating document: $error');
                                              }
                                            },
                                            icon: const Icon(Icons.check)
                                        ),
                                        IconButton(
                                            onPressed: () async {
                                              try {
                                                await FirebaseFirestore.instance
                                                    .collection('Users')
                                                    .doc(students[index]
                                                    .id) // Use the document ID directly
                                                    .update(
                                                    {'Status': 'Removed'});
                                                print(
                                                    'Document updated successfully');
                                              } catch (error) {
                                                print(
                                                    'Error updating document: $error');
                                              }
                                            },
                                            icon: const Icon(Icons.close)
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        }
                      }
                    }
                ),
                const SizedBox(height: 20,),
                const Text('Students in class room',style: TextStyle(fontSize: 20),),
                const SizedBox(height: 20,),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('Users').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final students = snapshot.data?.docs ?? [];
                    final activeStudent = students.where((user) {
                      final status = user['Status'] as String?;
                      final role = user['role'] as String?;
                      return status == 'Active' && role == 'Student';
                    }).toList(); // Filter out active students only
                    return SizedBox(
                      height: activeStudent.length * 100.0, // Assuming each ListTile has a height of 100. Adjust this value accordingly
                      width: double.infinity,
                      child: ListView.builder(
                        itemCount: activeStudent.length,
                        itemExtent: 100.0, // Height of each item in the list
                        itemBuilder: (context, index) {
                          final user = activeStudent[index].data();
                          if (user != null && user is Map<String, dynamic>) {
                            final status = user['Status'] as String?;
                            final role = user['role'] as String?;
                            if (status == 'Active' && role == 'Student') {
                              final course = user['Course'] as String?;
                              final firstName = user['First Name'] as String?;
                              final lastName = user['Last Name'] as String?;
                              final name = '${firstName ?? ''} ${lastName ?? ''} (${course ?? ''})';
                              final email = user['email'] as String?;
                              return ListTile(
                                title: Text(name ?? ''),
                                subtitle: Text(email ?? ''),
                                trailing: IconButton(
                                  onPressed: () async {
                                    try{
                                      await FirebaseFirestore.instance.collection('Users')
                                          .doc(activeStudent[index].id) // Use the document ID directly
                                          .update({'Status': 'Removed'});
                                      print('Uploading data sucessful');
                                    }catch (e){
                                      print('Error updating document: $e');
                                    }
                                  },
                                  icon: const Icon(Icons.exit_to_app_sharp),
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


//CUSTOM BOTTOM APP BAR
class CustBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustBottomBar({
    required this.currentIndex,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Assignment',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.group_solid),
          label: 'Meeting',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.chat_bubble),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.book),
          label: 'Material',
        ),
      ],
    );
  }
}

//CUSTOM APP BAR
class CustAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustAppBar({
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      title: const Text('Piyush Sharma Classes'),
      actions: [
        IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const Piyush_Settings();
              }));
            },
            icon: const Icon(Icons.settings)),
        IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const my_app_notification.Piyush_Notification();
              }));
            },
            icon: const Icon(Icons.notifications)),
      ],
    );
  }
}