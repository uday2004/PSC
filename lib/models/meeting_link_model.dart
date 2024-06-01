import 'package:flutter/material.dart';

class MeetingLink{
  final String meetingLink;
  final TimeOfDay fromTime;
  final TimeOfDay toTime;
  final String password;
  final String topic;
  final DateTime date;

  const MeetingLink({
    required this.meetingLink,
    required this.fromTime,
    required this.toTime,
    required this.password,
    required this.topic,
    required this.date,
});

  toJson(){
    return{
      "Meeting Link": meetingLink,
      "Date": date,
      "From": fromTime,
      "To": toTime,
      "Password": password,
      "Topic": topic,
    };
  }
}