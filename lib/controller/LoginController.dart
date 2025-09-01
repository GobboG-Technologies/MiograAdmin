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
  RxMap<String, dynamic> adminData = <String, dynamic>{}.obs;

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

      // 1. Sign in the user
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'USER-NOT-FOUND');
      }

      // 2. Fetch the admin document from the "admins" collection using the UID
      final adminDoc =
      await _firestore.collection('admins').doc(user.uid).get();

      if (adminDoc.exists && adminDoc.data()?['role'] == 'zone_admin') {
        final data = adminDoc.data()!;

        // Extract zones list from admin document
        final List<dynamic> zoneIds = data['zones'] ?? [];

        // 3. Fetch zone data for each zoneId
        List<Map<String, dynamic>> zonesData = [];
        for (String zoneId in zoneIds.cast<String>()) {
          final zoneDoc =
          await _firestore.collection('zone').doc(zoneId).get();

          if (zoneDoc.exists) {
            final zoneData = zoneDoc.data()!;
            zonesData.add({
              'zoneId': zoneData['zoneId'],
              'zoneName': zoneData['zoneName'],
              'zonePoints': zoneData['zonePoints'],
            });
          }
        }

        // 4. Prepare the data to be saved in SharedPreferences
        final sessionData = {
          'uid': user.uid,
          'name': data['name'],
          'email': data['email'],
          'role': data['role'],
          'primaryZoneId': data['primaryZone'],
          'zonesData': zonesData,
        };

        adminData.value = sessionData;

        // 5. Save the admin's session data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('adminSession', jsonEncode(sessionData));

        // 6. Navigate to the dashboard
        Get.offAllNamed('/zone-dashboard');
      } else {
        // If the user document doesn't exist or they aren't a zone_admin, sign them out.
        await _auth.signOut();
        Get.snackbar("Login Failed", "You do not have permission to log in.");
        Get.offAllNamed('/login'); // fallback
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Login Failed",
        e.message ?? "Invalid email or password. Please try again.",
      );
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// AUTO-LOGIN CHECK
  Future<void> checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSessionData = prefs.getString('adminSession');

    if (savedSessionData != null) {
      // If session data exists, decode it and go to the dashboard
      adminData.value = jsonDecode(savedSessionData);
      Get.offAllNamed('/zone-dashboard');
    } else {
      // No saved session → go to login page
      Get.offAllNamed('/login');
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('adminSession'); // Clear session data
    await _auth.signOut();
    adminData.clear(); // Clear local state
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
