import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../logIn/log_in.dart';
import '../logIn/verification.dart';
import '../student pages/home_page.dart';

class AuthRepo {
  // Singleton instance
  static final AuthRepo _instance = AuthRepo._privateConstructor();

  // Private constructor
  AuthRepo._privateConstructor();

  // Getter to access the instance
  static AuthRepo get instance => _instance;

  // Firebase authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  setInitialScreen(User? user) async {
    user==null
        ?Get.offAll(()=>const LogIn())
        :user.emailVerified
        ?Get.offAll(()=>const HomePage())
        :Get.offAll(()=>const Verification());
  }

  // Method to send email verification
  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      } else {
        throw 'User is either null or email is already verified.';
      }
    } catch (error) {
      throw 'Failed to send verification email: $error';
    }
  }
}

