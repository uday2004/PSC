class MeetingLink{
  final String meetingLink;
  final String fromTime;
  final String toTime;
  final String password;
  final String topic;

  const MeetingLink({
    required this.meetingLink,
    required this.fromTime,
    required this.toTime,
    required this.password,
    required this.topic,
});

  toJson(){
    return{
      "Meeting Link": meetingLink,
      "From": fromTime,
      "To": toTime,
      "Password": password,
      "Topic": topic,
    };
  }
}