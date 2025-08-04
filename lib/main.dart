import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:miogra_admin/views/business_view.dart';

import 'admin/SplashScreen.dart';
import 'admin/commisisons.dart';
import 'admin/termsandcondition.dart';
import 'controller/LoginController.dart';
import 'admin/loginPage.dart';
import 'admin/main_screen.dart';
import 'elements/Product/addProduct.dart'; // Zone Admin Dashboard

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const firebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyDB847Vc_EBTexUkiVOHxN5vzmhBRteg4Y",
    authDomain: "migora-f8f57.firebaseapp.com",
    projectId: "migora-f8f57",
    storageBucket: "migora-f8f57.appspot.com",
    messagingSenderId: "605102255517",
    appId: "1:605102255517:web:f1455bf6ad7256cb401374",
    measurementId: "G-MFMV671N00",
  );

  if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await Firebase.initializeApp(options: firebaseOptions);
  } else {
    await Firebase.initializeApp();
  }

  // Register LoginController globally (used in splash/login/dashboard)
  Get.put(LoginController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Miogra Zone Admin',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,

          // Define app routes
          getPages: [
            GetPage(name: '/splash', page: () => SplashScreen()),
            GetPage(name: '/splash', page: () => SplashScreen()),
            GetPage(name: '/login', page: () => LoginPage()),
            GetPage(name: '/zone-dashboard', page: () => DashboardScreen()),
          ],

          // Start with splash screen
          initialRoute: '/splash',
        );
      },
    );
  }
}
