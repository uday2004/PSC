import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/meeting_link_model.dart';

class MeetingLinkRepository extends GetxController {
  static MeetingLinkRepository get instance => Get.find<MeetingLinkRepository>();

  final FirebaseFirestore _dbLink = FirebaseFirestore.instance;

  Future<void> createLink(MeetingLink link, String course) async {
    try {
      await _dbLink
          .collection("Meeting Links")
          .doc(course.trim())
          .collection("Links")
          .add(link.toJson())
          .then((_) {
        Get.snackbar(
          "Success", "Meeting link has been created",
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } catch (error) {
      Get.snackbar(
        "Error", "Try again later",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
