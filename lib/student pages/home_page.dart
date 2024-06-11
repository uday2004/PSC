import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:psc/student%20pages/assignment.dart';
import 'package:psc/student%20pages/fees.dart';
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
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
          
              //Attendance
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text('Attendance',textAlign: TextAlign.center,style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
                      const SizedBox(height: 10,),
                      Text('Present: 10'),
                      Text('Absent: 10'),
                      Text('Total: 10'),
                      SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            startDegreeOffset: 90,
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                value: 10,
                                color: Colors.red,
                                radius: 40, // Adjust radius to make the sections thinner
                              ),
                              PieChartSectionData(
                                value: 10,
                                color: Colors.blue,
                                radius: 40, // Adjust radius to make the sections thinner
                                title: 'Waiting',
                              ),
                              PieChartSectionData(
                                value: 10,
                                color: Colors.green,
                                radius: 40, // Adjust radius to make the sections thinner
                                title: 'Paid',
                              ),
                            ],
                          )
                        ),
                      ),
                      ElevatedButton(
                        onPressed: (){},
                        child: const Text('Details',style: TextStyle(color: Colors.orangeAccent),),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20,),

              //Classes & Meeting Links
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                width: double.infinity,
                child: Column(
                  children: [
                    const Text('Classes',textAlign: TextAlign.center,style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),)
                  ],
                ),
              )
            ],
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
