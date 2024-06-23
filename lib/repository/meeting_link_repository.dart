import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseServices {
  final CollectionReference db = FirebaseFirestore.instance.collection('Meeting_Link');

  // Add the link to the server
  Future<void> addLink(int roomId, int password, String topic, DateTime date, TimeOfDay fromTime, TimeOfDay toTime,String course, String subject) async {
    try {
      final fromDateTime = DateTime(date.year, date.month, date.day, fromTime.hour, fromTime.minute);
      final toDateTime = DateTime(date.year, date.month, date.day, toTime.hour, toTime.minute);

      await FirebaseFirestore.instance.collection('MeetingLinks').add({
        'Room ID': roomId,
        'Course': course,
        'Subject': subject,
        'Password': password,
        'Topic': topic,
        'Date': Timestamp.fromDate(date),
        'From Time': Timestamp.fromDate(fromDateTime),
        'To Time': Timestamp.fromDate(toDateTime),
      });
    } catch (e) {
      log('Error adding link: $e');
    }
  }

  // Get meeting links ordered by 'Posted on' descending
  Stream<QuerySnapshot> getMeetingLinks() {
    final linkStream = db.orderBy('Posted on', descending: true).snapshots();
    return linkStream;
  }

  // Update a meeting link
  Future<void> updateLink(String documentId, {
    int? roomId,
    String? password,
    String? topic,
    DateTime? date,
    DateTime? fromTime,
    DateTime? toTime,
  }) async {
    Map<String, dynamic> updateData = {};
    if (roomId != null) updateData['Room ID'] = roomId;
    if (password != null) updateData['Password'] = password;
    if (topic != null) updateData['Topic'] = topic;
    if (date != null) updateData['Date'] = date;
    if (fromTime != null) updateData['From Time'] = fromTime;
    if (toTime != null) updateData['To Time'] = toTime;

    try {
      await db.doc(documentId).update(updateData);
    } catch (e) {
      throw ('Error updating meeting link: $e');
    }
  }

  // Delete a meeting link
  Future<void> deleteLink(String documentId) async {
    try {
      await db.doc(documentId).delete();
    } catch (e) {
      throw ('Error deleting meeting link: $e');
    }
  }
}
