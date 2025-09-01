import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

class DeliveryPersonAddController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Text controllers for all fields
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final whatsappController = TextEditingController();
  final addressController = TextEditingController();
  final drivingLicenseController = TextEditingController();
  final emergencyContact1Controller = TextEditingController();
  final emergencyContact2Controller = TextEditingController();
  final aadharController = TextEditingController();
  final panController = TextEditingController();
  final accountNoController = TextEditingController();
  final ifscController = TextEditingController();
  final upiController = TextEditingController();
  final zoneIdController = TextEditingController();

  // Document URLs (Aadhar, Pan, Driving License, Bank Passbook)
  final aadharUrlController = TextEditingController();
  final panUrlController = TextEditingController();
  final dlUrlController = TextEditingController();
  final bankPassbookUrlController = TextEditingController();

  var isLoading = false.obs;

  Future<void> addDeliveryPerson() async {
    try {
      isLoading.value = true;

      final data = {
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "email": emailController.text.trim(),
        "whatsapp number": whatsappController.text.trim(),
        "address": addressController.text.trim(),
        "Driving License": drivingLicenseController.text.trim(),
        "Emergency contact1": emergencyContact1Controller.text.trim(),
        "Emergency contact2": emergencyContact2Controller.text.trim(),
        "aadhar": aadharController.text.trim(),
        "pan": panController.text.trim(),
        "accountNo": accountNoController.text.trim(),
        "ifsc": ifscController.text.trim(),
        "upi": upiController.text.trim(),
        "zoneId": zoneIdController.text.trim(),
        "profile_image": "",
        "status": "offline",
        "createdAt": FieldValue.serverTimestamp(),
        "document": {
          "Aadhar": aadharUrlController.text.trim(),
          "Pan": panUrlController.text.trim(),
          "Driving License": dlUrlController.text.trim(),
          "Bank Passbook": bankPassbookUrlController.text.trim(),
        },
      };

      await _firestore.collection('deliveryboy').add(data);

      Get.snackbar("Success", "Delivery person added successfully!");
      clearFields();
    } catch (e) {
      Get.snackbar("Error", "Failed to add: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void clearFields() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    whatsappController.clear();
    addressController.clear();
    drivingLicenseController.clear();
    emergencyContact1Controller.clear();
    emergencyContact2Controller.clear();
    aadharController.clear();
    panController.clear();
    accountNoController.clear();
    ifscController.clear();
    upiController.clear();
    zoneIdController.clear();
    aadharUrlController.clear();
    panUrlController.clear();
    dlUrlController.clear();
    bankPassbookUrlController.clear();
  }


  Future<String?> pickAndUploadFile(String folderName) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String fileName = path.basename(file.path);

        final ref = FirebaseStorage.instance
            .ref()
            .child('deliveryboy/$folderName/$fileName');

        await ref.putFile(file);
        String url = await ref.getDownloadURL();
        return url;
      }
    } catch (e) {
      Get.snackbar("Error", "File upload failed: $e");
    }
    return null;
  }
}