class UserModel{
  final String fName;
  final String lName;
  final String emailID;
  final String course;
  final String password;
  final String status;
  final List<String> groupId;

  const UserModel({
    required this.fName,
    required this.lName,
    required this.emailID,
    required this.course,
    required this.password,
    required this.status,
    required this.groupId,
});
  toJson(){
    return{
      "First Name": fName,
      "Last Name": lName,
      "email": emailID,
      "Course": course,
      "role": "Student",
      "Status": "Waiting",
      "password": password,
      "Group ID": groupId
    };
  }
}