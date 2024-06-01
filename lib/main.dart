import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'package:psc/api/firebase_api.dart';
import 'package:psc/student%20pages/notification.dart';
import 'package:psc/theme/theme_provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'logIn/auth_page.dart';


final navigatorKey = GlobalKey<NavigatorState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  await FirebaseApi().initNotification();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const PSC(),
    ),
  );
}

class PSC extends StatelessWidget {
  const PSC({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      title: 'PSC',
      home: const AuthPage(),
      navigatorKey: navigatorKey,
      routes: {
        '/notification_screen': (context) => const Notification_Screen(),
      },
    );
  }
}
