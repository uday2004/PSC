import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'fees_list.dart';

class Piyush_Fees extends StatefulWidget {
  const Piyush_Fees({Key? key}) : super(key: key);

  @override
  State<Piyush_Fees> createState() => _Piyush_FeesState();
}

class _Piyush_FeesState extends State<Piyush_Fees> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Fees_due').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading data'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No data found'));
            }

            final feesDueDocs = snapshot.data!.docs;

            List<Widget> feesDueWidgets = feesDueDocs.map((doc) {
              final month = doc.id;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  margin: const EdgeInsets.all(5.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20,),
                      FutureBuilder<Map<String, dynamic>>(
                        future: fetchPieChartData(month),
                        builder: (context, pieChartSnapshot) {
                          if (pieChartSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (pieChartSnapshot.hasError) {
                            return const Center(child: Text('Error loading pie chart data'));
                          }

                          final pieChartData = pieChartSnapshot.data!;
                          final pieChartSections = pieChartData['sections'] as List<PieChartSectionData>;
                          final paidAmount = pieChartData['paidAmount'] as double;
                          final waitingAmount = pieChartData['waitingAmount'] as double;
                          final dueAmount = pieChartData['dueAmount'] as double;
                          final totalAmount = pieChartData['totalAmount'] as double;

                          final paidPercentage = totalAmount > 0 ? (paidAmount / totalAmount) * 100 : 0.0;
                          final waitingPercentage = totalAmount > 0 ? (waitingAmount / totalAmount) * 100 : 0.0;
                          final duePercentage = totalAmount > 0 ? (dueAmount / totalAmount) * 100 : 0.0;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: 200,
                                    child: PieChart(
                                      PieChartData(
                                        startDegreeOffset: 90,
                                        sections: pieChartSections,
                                        sectionsSpace: 0,
                                        centerSpaceRadius: 40,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Fees Summary for $month:',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(height: 5,),
                                  Text(
                                    'Paid: ₹${paidAmount.toStringAsFixed(2)} (${paidPercentage.toStringAsFixed(1)}%)',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    'Waiting: ₹${waitingAmount.toStringAsFixed(2)} (${waitingPercentage.toStringAsFixed(1)}%)',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Text(
                                    'Due: ₹${dueAmount.toStringAsFixed(2)} (${duePercentage.toStringAsFixed(1)}%)',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  Text(
                                    'Total Fees: ₹${totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      print(month);
                                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                                        return FeesList(month: month);
                                      }));
                                    },
                                    child: const Text('Details', style: TextStyle(color: Colors.orangeAccent)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      FirebaseFirestore.instance.collection('Fees_due').doc(month).collection('Users').doc().delete();
                                      FirebaseFirestore.instance.collection('Fees_due').doc(month).delete();
                                    },
                                    child: const Icon(CupertinoIcons.delete, color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList();

            return Column(
              children: feesDueWidgets,
            );
          },
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> fetchPieChartData(String month) async {
    final usersCollection = FirebaseFirestore.instance.collection('Fees_due').doc(month).collection('Users');
    final pendingSnapshot = await usersCollection.where('Status', isEqualTo: 'Pending').get();
    final paidSnapshot = await usersCollection.where('Status', isEqualTo: 'Paid').get();
    final waitingSnapshot = await usersCollection.where('Status', isEqualTo: 'Waiting').get();

    double totalAmount = 0;
    double totalPaidAmount = 0;
    double totalWaitingAmount = 0;
    double totalDueAmount = 0;

    for (var doc in pendingSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalDueAmount += data['Fees'] ?? 0;
      totalAmount += data['Fees'] ?? 0;
    }

    for (var doc in paidSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalPaidAmount += data['Fees'] ?? 0;
      totalAmount += data['Fees'] ?? 0;
    }

    for (var doc in waitingSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalWaitingAmount += data['Fees'] ?? 0;
      totalAmount += data['Fees'] ?? 0;
    }

    List<PieChartSectionData> sections = [
      PieChartSectionData(
        value: totalDueAmount,
        color: Colors.red,
        radius: 40, // Adjust radius to make the sections thinner
        title: 'Due',
      ),
      PieChartSectionData(
        value: totalWaitingAmount,
        color: Colors.blue,
        radius: 40, // Adjust radius to make the sections thinner
        title: 'Waiting',
      ),
      PieChartSectionData(
        value: totalPaidAmount,
        color: Colors.green,
        radius: 40, // Adjust radius to make the sections thinner
        title: 'Paid',
      ),
    ];

    return {
      'sections': sections,
      'paidAmount': totalPaidAmount,
      'waitingAmount': totalWaitingAmount,
      'dueAmount': totalDueAmount,
      'totalAmount': totalAmount,
    };
  }
}
