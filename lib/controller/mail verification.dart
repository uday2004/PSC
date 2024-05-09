import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../repository/authentication_repository.dart';

class MailVerificationController extends GetxController {
  late Timer _timer;

  @override
  void onInit() {
    super.onInit();
    sendVerificationEmail();
    setTimerForAutoRedirect();
  }

  Future<void> sendVerificationEmail() async {
    try {
      // Call the method to send email verification from your AuthRepo
      await AuthRepo.instance.sendEmailVerification();
      // Show a success message or handle the success scenario
      Get.snackbar(
        'Success',
        'Verification email sent successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (error) {
      // Show an error message or handle the error scenario
      Get.snackbar(
        'Error',
        'Failed to send verification email: $error',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  void setTimerForAutoRedirect(){
    _timer =Timer.periodic(const Duration(seconds: 3), (timer) {
      FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if(user!.emailVerified){
        timer.cancel();
        AuthRepo.instance.setInitialScreen(user);
      }
    });
  }
}

