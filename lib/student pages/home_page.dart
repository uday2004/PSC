import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:psc/student%20pages/setting.dart' as psc_settings;
import 'package:psc/student%20pages/study_material.dart';
import 'chats.dart';
import 'classes.dart';
import 'notification.dart' as my_app_notification;

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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _getUserClass();
  }

  Future<void> _getUserClass() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();

      Map<String, dynamic>? userData = docSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        setState(() {
          userClass = userData['Course'];
        });
        loadExistingFiles(); // Load existing files once user class is fetched
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadExistingFiles() async {
    try {
      setState(() {
        isLoading = true;
      });
      final listRef = firebase_storage.FirebaseStorage.instance.ref().child("Study Material/$userClass");
      final firebase_storage.ListResult result = await listRef.listAll();
      setState(() {
        existingFiles = result.items.map((item) => item.name).toList();
      });
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
      final ref = firebase_storage.FirebaseStorage.instance.ref().child("Study Material/$userClass/$fileName");
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
          const Classes(),
          const Chats(),
          const StudyMaterial(),
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
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: RefreshIndicator(
          onRefresh: loadExistingFiles,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text('Assignments:', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: Colors.black,
                    ),
                  ),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    shrinkWrap: true,
                    itemCount: existingFiles.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(existingFiles[index]),
                        trailing: IconButton(
                          icon: const Icon(CupertinoIcons.down_arrow),
                          onPressed: () => downloadFile(existingFiles[index]),
                        ),
                      );
                    },
                  ),
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
          icon: Icon(CupertinoIcons.chat_bubble),
          label: 'Chats',
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
                return psc_settings.Settings();
              }));
            },
            icon: const Icon(Icons.settings)),
        IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const my_app_notification.Notification();
              }));
            },
            icon: const Icon(Icons.notifications)),
      ],
    );
  }
}
