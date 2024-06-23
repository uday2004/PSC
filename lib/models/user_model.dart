class UserModel {
  final String fName;
  final String lName;
  final String emailID;
  final String course;
  final String password;
  final String status;
  final String board;
  final List<String> subject;

  UserModel({
    required this.fName,
    required this.lName,
    required this.emailID,
    required this.course,
    required this.password,
    required this.status,
    required this.board,
    required this.subject,
  });

  Map<String, dynamic> toJson() {
    return {
      "First Name": fName,
      "Last Name": lName,
      "email": emailID,
      "Course": course,
      "role": "Student",
      "Status": "Waiting",
      "password": password,
      "Board": board,
      "Subject": subject,
    };
  }
}