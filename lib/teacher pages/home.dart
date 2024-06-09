import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:psc/teacher%20pages/notification.dart';
import 'package:psc/teacher%20pages/personal%20info.dart';
import 'package:psc/teacher%20pages/settings.dart';
import 'package:psc/teacher%20pages/study_material.dart';
import 'assignment.dart';
import 'classes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'fees.dart';

class Piyush_Home extends StatefulWidget {
  const Piyush_Home({super.key});

  @override
  State<Piyush_Home> createState() => _Piyush_HomeState();
}

class _Piyush_HomeState extends State<Piyush_Home> {
  late PageController _pageController;
  int _currentIndex = 0;
  int choiceIndex = 0;

  Future<void> _refresh() {
    return Future.delayed(const Duration(seconds: 0));
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
      appBar: const CustAppBar(),
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
          const PiyushAssignment(),
          const PiyushClasses(),
          const Piyush_Fees(),
          const PiyushStudyMaterial(),
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
            scrollDirection: Axis.vertical,
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text('Students in waiting room', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 20),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('Users').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final students = snapshot.data?.docs ?? [];
                        final waitingStudents = students.where((user) {
                          final data = user.data() as Map<String, dynamic>;
                          final status = data['Status'] as String?;
                          final role = data['role'] as String?;
                          return status == 'Waiting' && role == 'Student';
                        }).toList();

                        if (waitingStudents.isEmpty) {
                          return const Text('No one is in the waiting room...');
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: waitingStudents.length,
                          itemBuilder: (context, index) {
                            final user = waitingStudents[index].data() as Map<String, dynamic>?;
                            if (user != null) {
                              final firstName = user['First Name'] as String?;
                              final lastName = user['Last Name'] as String?;
                              final course = user['Course'] as String?;
                              final email = user['email'] as String?;
                              final name = '${firstName ?? ''} ${lastName ?? ''} (${course ?? ''})';

                              return ListTile(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return PersonalInfo(
                                      userData: user,
                                      userId: waitingStudents[index].id,
                                    );
                                  }));
                                },
                                title: Text(name),
                                subtitle: Text(email ?? ''),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        try {
                                          await FirebaseFirestore.instance.collection('Users')
                                              .doc(waitingStudents[index].id) // Use the document ID directly
                                              .update({'Status': 'Active'});
                                        } catch (e) {
                                          print('Error updating document: $e');
                                        }
                                      },
                                      icon: const Icon(Icons.check),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        try {
                                          await FirebaseFirestore.instance.collection('Users')
                                              .doc(waitingStudents[index].id) // Use the document ID directly
                                              .update({'Status': 'Removed'});
                                        } catch (e) {
                                          print('Error updating document: $e');
                                        }
                                      },
                                      icon: const Icon(Icons.close_outlined),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Students in class room', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 20),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('Users').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final students = snapshot.data?.docs ?? [];
                        final activeStudents = students.where((user) {
                          final data = user.data() as Map<String, dynamic>;
                          final status = data['Status'] as String?;
                          final role = data['role'] as String?;
                          return status == 'Active' && role == 'Student';
                        }).toList();

                        if (activeStudents.isEmpty) {
                          return const Text('No one is in the class room...');
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: activeStudents.length,
                          itemBuilder: (context, index) {
                            final user = activeStudents[index].data() as Map<String, dynamic>?;
                            if (user != null) {
                              final firstName = user['First Name'] as String?;
                              final lastName = user['Last Name'] as String?;
                              final course = user['Course'] as String?;
                              final email = user['email'] as String?;
                              final name = '${firstName ?? ''} ${lastName ?? ''} (${course ?? ''})';

                              return ListTile(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return PersonalInfo(
                                      userData: user,
                                      userId: activeStudents[index].id,
                                    );
                                  }));
                                },
                                title: Text(name),
                                subtitle: Text(email ?? ''),
                                trailing: IconButton(
                                  onPressed: () async {
                                    try {
                                      await FirebaseFirestore.instance.collection('Users')
                                          .doc(activeStudents[index].id) // Use the document ID directly
                                          .update({'Status': 'Removed'});
                                    } catch (e) {
                                      print('Error updating document: $e');
                                    }
                                  },
                                  icon: const Icon(Icons.exit_to_app_sharp),
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// CUSTOM BOTTOM APP BAR
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
          icon: Icon(Icons.home_outlined,),
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
          icon: Icon(Icons.currency_rupee),
          label: 'Fees',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.book),
          label: 'Material',
        ),
      ],
      selectedItemColor: Colors.orangeAccent,  // Customize the selected item text color
      unselectedItemColor: Colors.white,  // Customize the unselected item text color
      backgroundColor: Colors.blue,
    );
  }
}

// CUSTOM APP BAR
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
                return const NotificationPiyush();
              }));
            },
            icon: const Icon(Icons.notifications)),
      ],
    );
  }
}
