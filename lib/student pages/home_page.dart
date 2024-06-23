import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'assignment.dart';
import 'classes.dart';
import 'fees.dart';
import 'notification.dart';
import 'setting.dart';
import 'study_material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  int _currentIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String currentUserUid = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    getCurrentUser();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> getCurrentUser() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      setState(() {
        currentUserUid = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: const CustAppBar(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          HomePageContent(context),
          const Assignment(),
          const Classes(),
          const StudyMaterial(),
          const Fees(),
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

  Widget HomePageContent(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Meeting Links Section
              Column(
                children: [
                  const Text(
                    'Meeting Links',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(currentUserUid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (userSnapshot.hasError) {
                        return Text('Error: ${userSnapshot.error}');
                      }
                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return const Text('No meeting links available');
                      }

                      // Fetch user's course and selected subjects
                      String userCourse = userSnapshot.data!.get('Course') ?? '';
                      List<dynamic> selectedSubjects = userSnapshot.data!.get('Subject') ?? [];

                      // Query meeting links collection
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('MeetingLinks')
                            .where('course', isEqualTo: userCourse)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> meetingSnapshot) {
                          if (meetingSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (meetingSnapshot.hasError) {
                            return Text('Error: ${meetingSnapshot.error}');
                          }
                          if (meetingSnapshot.data == null || meetingSnapshot.data!.docs.isEmpty) {
                            return const Text('No meeting links available');
                          }

                          // Filter meeting links based on the user's subjects
                          List<QueryDocumentSnapshot> filteredDocs = meetingSnapshot.data!.docs.where((doc) {
                            return selectedSubjects.contains(doc['subject']);
                          }).toList();

                          if (filteredDocs.isEmpty) {
                            return const Text('No meeting links available');
                          }

                          // Build list of meeting link cards
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: filteredDocs
                                .map((doc) => _buildMeetingLinkCard(doc))
                                .toList(),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeetingLinkCard(QueryDocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    DateTime dateTime = data['date'] != null
        ? (data['date'] as Timestamp).toDate()
        : DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy – kk:mm').format(dateTime);

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['topic'] ?? 'No topic',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Room ID: ${data['meetingLink']}'),
            const SizedBox(height: 8),
            Text('Password: ${data['password']}'),
            const SizedBox(height: 8),
            Text('Date and time: $formattedDate'),
            const SizedBox(height: 8),
            Text('Subject: ${data['subject']}'),
          ],
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
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Assignment',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.video_camera),
          label: 'Classes',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.book),
          label: 'Material',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.currency_rupee),
          label: 'Fees',
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
                return const PSCSettings();
              }));
            },
            icon: const Icon(Icons.settings)),
        IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const Notification_Screen();
              }));
            },
            icon: const Icon(Icons.notifications)),
      ],
    );
  }
}
