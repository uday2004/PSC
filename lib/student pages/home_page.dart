import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:psc/student%20pages/fees.dart';
import 'package:psc/student%20pages/setting.dart' as psc_settings;
import 'package:psc/student%20pages/setting.dart';
import 'package:psc/student%20pages/study_material.dart';
import 'classes.dart';
import 'notification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  int _currentIndex = 0;
  List<String> existingFiles = [];
  bool isLoading = false;
  late String userClass;
  late String userSub;
  late String userBoard;
  String currentSubject = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _getUserClass();
  }

  Future<void> _getUserClass() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      try {
        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .get();

        Map<String, dynamic>? userData = docSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          setState(() {
            userClass = userData['Course'];
            userSub = userData['Subject'];
            userBoard = userData['Board'];
          });
          loadExistingFiles(); // Load existing files once user class is fetched
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user data: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadExistingFiles({String subject = ''}) async {
    try {
      setState(() {
        isLoading = true;
        currentSubject = subject;
      });

      final List<firebase_storage.Reference> references = [];

      if (userClass == 'Class 11' || userClass == 'Class 12') {
        if (subject.isNotEmpty) {
          references.add(firebase_storage.FirebaseStorage.instance
              .ref()
              .child("Study Material/$userClass/$userBoard/$subject"));
        } else if (userSub == 'Economics' || userSub == 'Mathematics') {
          references.add(firebase_storage.FirebaseStorage.instance
              .ref()
              .child("Study Material/$userClass/$userBoard/$userSub"));
        } else if (userSub == 'Both(Maths & Economics)') {
          setState(() {
            existingFiles = ['Mathematics', 'Economics'];
          });
          return;
        }

        final List<String> files = [];
        for (final ref in references) {
          final firebase_storage.ListResult result = await ref.listAll();
          files.addAll(result.items.map((item) => item.name));
        }

        setState(() {
          existingFiles = files;
        });
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading files: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<File?> downloadFile(String fileName) async {
    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("Study Material/$userClass/$userBoard/${currentSubject.isEmpty ? '' : '$currentSubject/'}$fileName");
      final Directory tempDir = await getTemporaryDirectory();
      final String tempFilePath = '${tempDir.path}/$fileName';
      await ref.writeToFile(File(tempFilePath));
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = '${appDocDir.path}/$fileName';
      final File tempFile = File(tempFilePath);
      await tempFile.copy(appDocPath);
      await tempFile.delete();
      return File(appDocPath);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: currentSubject.isNotEmpty
          ? AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                loadExistingFiles(); // Go back to the subjects list
              },
            ),
            const Text('Files'),
          ],
        ),
      )
          : const CustAppBar(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          HomePageContent(context),
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RefreshIndicator(
          onRefresh: () => loadExistingFiles(subject: currentSubject),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text('Assignments:', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 10),
                if (currentSubject.isNotEmpty)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          setState(() {
                            currentSubject = '';
                            existingFiles = ['Mathematics', 'Economics'];
                          });
                        },
                      ),
                      Text(
                        currentSubject,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: existingFiles.length,
                  itemBuilder: (context, index) {
                    if (userSub == 'Both(Maths & Economics)' &&
                        currentSubject.isEmpty) {
                      return ListTile(
                        title: Text(existingFiles[index]),
                        onTap: () => loadExistingFiles(
                            subject: existingFiles[index]),
                      );
                    } else {
                      return ListTile(
                        title: Text(existingFiles[index]),
                        trailing: currentSubject.isEmpty
                            ? null
                            : IconButton(
                          icon: const Icon(CupertinoIcons.down_arrow),
                          onPressed: () => downloadFile(existingFiles[index]),
                        ),
                        onTap: currentSubject.isEmpty
                            ? () {
                          loadExistingFiles(
                              subject: existingFiles[index]);
                        }
                            : null,
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
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
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.group_solid),
          label: 'Meeting',
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
