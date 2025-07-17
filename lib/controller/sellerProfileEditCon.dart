import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileEditController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  var profileImage = ''.obs;
  String? sellerId; // Store current seller id for update

  // Call this to load seller data into form for editing
  void loadSellerData(String id) async {
    sellerId = id;
    final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
    if (doc.exists) {
      final data = doc.data()!;
      usernameController.text = data['name'] ?? '';
      phoneController.text = data['phone'] ?? '';
      emailController.text = data['email'] ?? '';
      profileImage.value = data['imageUrl'] ?? '';
    }
  }

  // Clear form for adding new seller
  void clearForm() {
    sellerId = null;
    usernameController.clear();
    phoneController.clear();
    emailController.clear();
    profileImage.value = '';
  }
  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) return;

    final data = {
      'name': usernameController.text.trim(),
      'phone': phoneController.text.trim(),
      'email': emailController.text.trim(),
      'imageUrl': profileImage.value,
    };

    try {
      if (sellerId != null) {
        await FirebaseFirestore.instance.collection('users').doc(sellerId).update(data);
        Get.snackbar(
          'Success',
          'Seller updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } else {
        await FirebaseFirestore.instance.collection('users').add(data);
        Get.snackbar(
          'Success',
          'Seller added successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds:10),
        );
      }
      await Future.delayed(Duration(milliseconds: 300)); // <-- Add small delay
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save seller: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

}
