import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  RxBool isLoading = false.obs;
  RxMap<String, dynamic> zoneData = <String, dynamic>{}.obs;

  /// LOGIN FUNCTION
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please enter email and password");
      return;
    }

    try {
      isLoading.value = true;

      // Sign in
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Fetch zone data for this zone admin
      final zoneDoc = await _firestore
          .collection('zone')
          .where('adminEmail', isEqualTo: email)
          .limit(1)
          .get();

      if (zoneDoc.docs.isNotEmpty) {
        zoneData.value = zoneDoc.docs.first.data();
        zoneData['zoneId'] = zoneDoc.docs.first.id;

        // Save login data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('zoneData', jsonEncode(zoneData));
      }

      // Navigate to zone dashboard
      Get.offAllNamed('/zone-dashboard');
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Login Failed", e.message ?? "Invalid credentials");
    } finally {
      isLoading.value = false;
    }
  }

  /// AUTO-LOGIN CHECK
  Future<void> checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedZoneData = prefs.getString('zoneData');

    if (savedZoneData != null) {
      zoneData.value = jsonDecode(savedZoneData);
      Get.offAllNamed('/zone-dashboard'); // Go straight to dashboard
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _auth.signOut();
    Get.offAllNamed('/login');
  }


  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
// zoneId  yVuZG4sPLW0izNXS32Qu