import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

class EditDeliveryPersonController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Document ID of the delivery person being edited
  final String deliveryPersonId;

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

  // Document URLs
  final aadharUrlController = TextEditingController();
  final panUrlController = TextEditingController();
  final dlUrlController = TextEditingController();
  final bankPassbookUrlController = TextEditingController();
  final profileImageUrl = ''.obs;

  var isLoading = false.obs;
  var isUploading = false.obs;

  EditDeliveryPersonController(this.deliveryPersonId);

  @override
  void onInit() {
    super.onInit();
    fetchDeliveryPersonDetails();
  }

  /// Fetch delivery person data from Firestore
  Future<void> fetchDeliveryPersonDetails() async {
    isLoading.value = true;
    try {
      DocumentSnapshot doc = await _firestore.collection('deliveryboy').doc(deliveryPersonId).get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;

        // Populate text fields
        nameController.text = data['name'] ?? '';
        phoneController.text = data['phone'] ?? '';
        emailController.text = data['email'] ?? '';
        whatsappController.text = data['whatsapp number'] ?? '';
        addressController.text = data['address'] ?? '';
        drivingLicenseController.text = data['Driving License'] ?? '';
        emergencyContact1Controller.text = data['Emergency contact1'] ?? '';
        emergencyContact2Controller.text = data['Emergency contact2'] ?? '';
        aadharController.text = data['aadhar'] ?? '';
        panController.text = data['pan'] ?? '';
        accountNoController.text = data['accountNo'] ?? '';
        ifscController.text = data['ifsc'] ?? '';
        upiController.text = data['upi'] ?? '';
        zoneIdController.text = data['zoneId'] ?? '';
        profileImageUrl.value = data['profile_image'] ?? '';

        // Populate document URLs
        if (data['document'] != null) {
          aadharUrlController.text = data['document']['Aadhar'] ?? '';
          panUrlController.text = data['document']['Pan'] ?? '';
          dlUrlController.text = data['document']['Driving License'] ?? '';
          bankPassbookUrlController.text = data['document']['Bank Passbook'] ?? '';
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Update delivery person data
  Future<void> updateDeliveryPerson() async {
    isLoading.value = true;
    try {
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
        "profile_image": profileImageUrl.value,
        "document": {
          "Aadhar": aadharUrlController.text.trim(),
          "Pan": panUrlController.text.trim(),
          "Driving License": dlUrlController.text.trim(),
          "Bank Passbook": bankPassbookUrlController.text.trim(),
        },
      };

      await _firestore.collection('deliveryboy').doc(deliveryPersonId).update(data);
      Get.back(); // Go back to the previous screen
      Get.snackbar("Success", "Delivery person updated successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to update: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Pick and upload a file (for documents or profile image)
  Future<String?> pickAndUploadFile(String folderName, {bool isProfileImage = false}) async {
    isUploading.value = true;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String fileName = isProfileImage ? 'profile.jpg' : path.basename(file.path);

        final ref = _storage.ref().child('deliveryboy/$folderName/$fileName');
        await ref.putFile(file);
        String url = await ref.getDownloadURL();

        if (isProfileImage) {
          profileImageUrl.value = url;
        }

        Get.snackbar("Success", "${isProfileImage ? 'Profile image' : 'Document'} uploaded successfully.");
        return url;
      }
    } catch (e) {
      Get.snackbar("Error", "File upload failed: $e");
    } finally {
      isUploading.value = false;
    }
    return null;
  }
}