import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:miogra_admin/admin/main_screen.dart';

import 'admin/loginPage.dart';
 // Add this import
import 'controller/LoginController.dart';
import 'elements/Business/AddBusness.dart';
import 'elements/Order/orderReqPage.dart';
import 'elements/Product/addProduct.dart';

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

  // Register your LoginController
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
          title: 'Miogra Admin',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          home: DashboardScreen(), // now uses GetView<LoginController>
        );
      },
    );
  }
}
