import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/LoginController.dart';

class SplashScreen extends StatelessWidget {
  final LoginController loginController = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    // Trigger auto-login check after build
    Future.delayed(Duration.zero, () async {
      await loginController.checkAutoLogin();
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/M.png", height: 100),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              "Checking login status...",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
