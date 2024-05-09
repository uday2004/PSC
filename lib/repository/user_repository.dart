import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';

class UserRepository extends GetxController{
  static UserRepository get instance => Get.find<UserRepository>();

  final _db = FirebaseFirestore.instance;

  createUser (UserModel user) async {
    await _db.collection("Users").add(user.toJson()).whenComplete(() =>
        Get.snackbar(
          "Sucerss", "Your account has been created",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        ))
        .catchError((error, stackTrace){
      Get.snackbar(
        "Error", "Try again later",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
    });
  }
}