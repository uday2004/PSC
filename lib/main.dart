import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'package:psc/theme/theme_provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';


import 'logIn/auth_page.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(), // Provide your ThemeProvider
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
    );
  }
}
