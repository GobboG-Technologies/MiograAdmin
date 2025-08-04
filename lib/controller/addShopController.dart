

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class DocFile {
  final String name;
  final String? path;
  final Uint8List? bytes;

  DocFile({required this.name, this.path, this.bytes});
}

class AddShopController extends GetxController {
  // Loading state
  var isLoading = false.obs;

  // Form field controllers
  final sellerName = TextEditingController();
  final businessName = TextEditingController();
  final aadharNumber = TextEditingController();
  final panNumber = TextEditingController();
  final gstNumber = TextEditingController();
  final contact = TextEditingController();
  final alternateContact = TextEditingController();
  final doorNumber = TextEditingController();
  final streetName = TextEditingController();
  final area = TextEditingController();
  final pinNumber = TextEditingController();
  final fssai = TextEditingController();

  // Bank details
  final bankName = TextEditingController();
  final accountNumber = TextEditingController();
  final ifscCode = TextEditingController();
  final upiId = TextEditingController();
  final gpayNumber = TextEditingController();

  // Image and docs state variables
  var profileImage = Rx<XFile?>(null);
  var uploadedDocs = <String, DocFile?>{}.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- File Picking Logic ---

  Future<void> pickProfileImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        profileImage.value = pickedFile;
        Get.snackbar("Success", "Image selected successfully", backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Error picking image: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> pickPdfFile(String docType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        uploadedDocs[docType] = DocFile(
          name: file.name,
          path: kIsWeb ? null : file.path,
          bytes: kIsWeb ? file.bytes : null,
        );
        Get.snackbar("Success", "$docType uploaded successfully", backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Error picking $docType: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void deletePdfFile(String docType) {
    uploadedDocs.remove(docType);
    Get.snackbar("Removed", "$docType has been removed", backgroundColor: Colors.orange, colorText: Colors.white);
  }

  // --- Firebase Upload and Save Logic ---

  Future<String?> _uploadFile(String folder, String fileName, {String? path, Uint8List? bytes}) async {
    if (path == null && bytes == null) return null;

    try {
      final ref = _storage.ref(folder).child(fileName);
      UploadTask uploadTask;

      if (kIsWeb) {
        uploadTask = ref.putData(bytes!);
      } else {
        uploadTask = ref.putFile(File(path!));
      }

      final snapshot = await uploadTask.whenComplete(() => {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading file: $e");
      return null;
    }
  }

  Future<void> addShop() async {
    // Basic Validation
    if (businessName.text.isEmpty || contact.text.isEmpty || profileImage.value == null) {
      Get.snackbar("Validation Error", "Please fill Business Name, Contact, and add a Profile Image.", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      // 1. Upload Profile Image
      String? profileImageUrl;
      if (profileImage.value != null) {
        final image = profileImage.value!;
        final fileBytes = kIsWeb ? await image.readAsBytes() : null;
        final filePath = kIsWeb ? null : image.path;
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}';
        profileImageUrl = await _uploadFile('shop_images', fileName, path: filePath, bytes: fileBytes);
      }

      // 2. Upload Documents
      final Map<String, String> docUrls = {};
      for (var entry in uploadedDocs.entries) {
        if (entry.value != null) {
          final doc = entry.value!;
          final fileName = '${entry.key}_${DateTime.now().millisecondsSinceEpoch}.pdf';
          final url = await _uploadFile('shop_documents', fileName, path: doc.path, bytes: doc.bytes);
          if (url != null) {
            docUrls[entry.key] = url;
          }
        }
      }

      // 3. Save all data to Firestore
      await _firestore.collection('Shops').add({
        'sellerName': sellerName.text.trim(),
        'businessName': businessName.text.trim(),
        'aadharNumber': aadharNumber.text.trim(),
        'panNumber': panNumber.text.trim(),
        'gstNumber': gstNumber.text.trim(),
        'contact': contact.text.trim(),
        'alternateContact': alternateContact.text.trim(),
        'address': {
          'doorNumber': doorNumber.text.trim(),
          'streetName': streetName.text.trim(),
          'area': area.text.trim(),
          'pinNumber': pinNumber.text.trim(),
        },
        'fssai': fssai.text.trim(),
        'bankDetails': {
          'name': bankName.text.trim(),
          'accountNumber': accountNumber.text.trim(),
          'ifscCode': ifscCode.text.trim(),
          'upiId': upiId.text.trim(),
          'gpayNumber': gpayNumber.text.trim(),
        },
        'profileImageUrl': profileImageUrl,
        'documentUrls': docUrls,
        'status': 'pending', // Default status
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Success', 'Shop added successfully and is pending approval.', backgroundColor: Colors.green, colorText: Colors.white);
      clearAllFields();
      Get.back(); // Go back to the previous screen

    } catch (e) {
      Get.snackbar('Error', 'Failed to add shop: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void clearAllFields() {
    sellerName.clear();
    businessName.clear();
    aadharNumber.clear();
    panNumber.clear();
    gstNumber.clear();
    contact.clear();
    alternateContact.clear();
    doorNumber.clear();
    streetName.clear();
    area.clear();
    pinNumber.clear();
    fssai.clear();
    bankName.clear();
    accountNumber.clear();
    ifscCode.clear();
    upiId.clear();
    gpayNumber.clear();
    profileImage.value = null;
    uploadedDocs.clear();
  }
}