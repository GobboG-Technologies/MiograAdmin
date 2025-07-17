import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin/main_screen.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Error", "Please enter email and password");
      return;
    }

    isLoading.value = true;

    try {
      // Firebase Auth login
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Check admin role from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('admins')
          .where('email', isEqualTo: emailController.text.trim())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        _showDialog("Login Failed", "No admin record found.");
        return;
      }

      final userData = snapshot.docs.first.data();
      final role = userData['role'];
      final zone = userData['zone'];

      print("✅ Logged in as: $role in zone $zone");

      if (role == 'zone_admin') {
        _showDialog("Login Successful", "Welcome to $zone zone", () {
          Get.back(); // Close dialog
          Get.off(() => DashboardScreen()); // Replace with your dashboard
        });
      } else {
        _showDialog("Access Denied", "You are not authorized to access this app.");
      }
    } on FirebaseAuthException catch (e) {
      _showDialog("Login Failed", e.message ?? "Something went wrong");
    } catch (e) {
      _showDialog("Error", "Unexpected error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _showDialog(String title, String message, [VoidCallback? onOk]) {
    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 300,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5D348B))),
                    SizedBox(height: 10),
                    Text(message, textAlign: TextAlign.center),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        if (onOk != null) onOk();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5D348B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("OK", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
