import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
// Only import dart:html when on web
import 'dart:html' as html show FileUploadInputElement, FileReader, Blob, File;

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

  // New Firebase Storage support
  var selectedProfileImage = Rx<XFile?>(null);
  var selectedDocuments = <String, XFile?>{}.obs; // For document files

  var isLoading = false.obs;
  var isUploading = false.obs;

  EditDeliveryPersonController(this.deliveryPersonId);

  @override
  void onInit() {
    super.onInit();
    testFirebaseStorageConnection();
    fetchDeliveryPersonDetails();
  }

  // Test Firebase Storage connection
  Future<void> testFirebaseStorageConnection() async {
    try {
      print("Testing Firebase Storage connection for delivery persons...");
      final ref = FirebaseStorage.instance.ref().child('test/delivery-connection-test.txt');
      await ref.putString('Firebase Storage working for delivery persons!');
      print("Firebase Storage connection successful for delivery persons");
    } catch (e) {
      print("Firebase Storage test failed for delivery persons: $e");
      Get.snackbar(
        "Storage Warning",
        "Firebase Storage connection issue. File uploads may not work properly.",
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
        duration: Duration(seconds: 3),
      );
    }
  }

  // Web-specific image picker
  Future<void> pickImageWeb({bool isProfileImage = true}) async {
    if (!kIsWeb) return;

    try {
      html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = isProfileImage ? 'image/*' : '*/*';
      uploadInput.click();

      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files != null && files.length == 1) {
          final file = files[0];

          // Check file size (5MB limit)
          const maxSize = 5 * 1024 * 1024;
          if (file.size > maxSize) {
            Get.snackbar(
              "File Too Large",
              "Please select a file smaller than 5MB. Current size: ${(file.size / 1024 / 1024).toStringAsFixed(1)}MB",
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: Duration(seconds: 3),
            );
            return;
          }

          // Create XFile-like object for compatibility
          final bytes = await _readFileAsBytes(file);
          final tempXFile = XFile.fromData(bytes, name: file.name);

          if (isProfileImage) {
            selectedProfileImage.value = tempXFile;
          }

          print("File selected: ${file.name} (${(file.size / 1024).toStringAsFixed(1)} KB)");

          Get.snackbar(
            "Success",
            "File selected: ${file.name}",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
        }
      });
    } catch (e) {
      print("Error picking file: $e");
      Get.snackbar(
        "Error",
        "Failed to pick file: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Mobile/Desktop file picker
  Future<void> pickFileMobile({bool isProfileImage = true}) async {
    try {
      if (isProfileImage) {
        // Use image picker for profile images
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          const maxSize = 5 * 1024 * 1024;

          if (bytes.length > maxSize) {
            Get.snackbar(
              "File Too Large",
              "Please select an image smaller than 5MB.",
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: Duration(seconds: 3),
            );
            return;
          }

          selectedProfileImage.value = pickedFile;
          Get.snackbar(
            "Success",
            "Profile image selected: ${pickedFile.name}",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
        }
      } else {
        // Use file picker for documents
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowedExtensions: null,
        );

        if (result != null && result.files.single.path != null) {
          final file = result.files.single;
          if (file.size > 5 * 1024 * 1024) {
            Get.snackbar(
              "File Too Large",
              "Please select a file smaller than 5MB.",
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            return;
          }

          // Convert to XFile for consistency
          final xFile = XFile(file.path!);
          // Store in selectedDocuments if needed for batch upload

          Get.snackbar(
            "Success",
            "Document selected: ${file.name}",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to pick file: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Helper method to read file bytes for web
  Future<Uint8List> _readFileAsBytes(html.File file) async {
    if (!kIsWeb) throw UnsupportedError('This method is only supported on web');

    final completer = Completer<Uint8List>();
    final reader = html.FileReader();

    reader.onLoad.listen((_) {
      completer.complete(reader.result as Uint8List);
    });

    reader.onError.listen((error) {
      completer.completeError(error);
    });

    reader.readAsArrayBuffer(file);
    return completer.future;
  }

  // Enhanced Firebase Storage upload method
  Future<String?> uploadFileToFirebase(XFile file, String uploadPath) async {
    try {
      print("Starting Firebase Storage upload: $uploadPath");

      final ref = _storage.ref().child(uploadPath);
      final Uint8List bytes = await file.readAsBytes();

      UploadTask task;
      if (kIsWeb) {
        // Use blob upload for web
        final blob = html.Blob([bytes]);
        task = ref.putBlob(blob);
      } else {
        // Use data upload for mobile/desktop
        task = ref.putData(
          bytes,
          SettableMetadata(
            contentType: _getContentType(file.name),
            cacheControl: 'public, max-age=3600',
          ),
        );
      }

      final snap = await task.timeout(
        Duration(seconds: 60),
        onTimeout: () {
          task.cancel();
          throw TimeoutException('Upload timeout after 60 seconds', Duration(seconds: 60));
        },
      );

      final downloadURL = await snap.ref.getDownloadURL();
      print("Firebase Storage upload successful: $downloadURL");
      return downloadURL;
    } catch (e) {
      print("Firebase Storage upload failed: $e");
      Get.snackbar(
        "Upload Error",
        "Failed to upload file: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Helper method to determine content type
  String _getContentType(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
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

  /// Enhanced update method with Firebase Storage support
  Future<void> updateDeliveryPerson() async {
    isLoading.value = true;
    try {
      String currentProfileImageUrl = profileImageUrl.value;

      // Upload new profile image if selected
      if (selectedProfileImage.value != null) {
        isUploading.value = true;
        try {
          final uploadPath = 'deliveryboy/$deliveryPersonId/profile.jpg';
          final uploadedUrl = await uploadFileToFirebase(selectedProfileImage.value!, uploadPath);
          if (uploadedUrl != null) {
            currentProfileImageUrl = uploadedUrl;
            profileImageUrl.value = uploadedUrl;
          }
        } catch (e) {
          print("Profile image upload failed: $e");
          // Ask user if they want to continue without updating the image
          final bool? continueWithoutImage = await Get.dialog<bool>(
            AlertDialog(
              title: Text("Image Upload Failed"),
              content: Text("Failed to upload profile image. Continue without updating the image?"),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  child: Text("Continue"),
                ),
              ],
            ),
          );

          if (continueWithoutImage != true) {
            return;
          }
        } finally {
          isUploading.value = false;
        }
      }

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
        "profile_image": currentProfileImageUrl,
        "document": {
          "Aadhar": aadharUrlController.text.trim(),
          "Pan": panUrlController.text.trim(),
          "Driving License": dlUrlController.text.trim(),
          "Bank Passbook": bankPassbookUrlController.text.trim(),
        },
        "updatedAt": FieldValue.serverTimestamp(),
        "platform": kIsWeb ? 'web' : 'mobile',
        "uploadMethod": selectedProfileImage.value != null ? 'firebase_storage' : 'existing',
      };

      await _firestore.collection('deliveryboy').doc(deliveryPersonId).update(data);
      Get.back(); // Go back to the previous screen
      Get.snackbar("Success", "Delivery person updated successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to update: $e");
    } finally {
      isLoading.value = false;
      isUploading.value = false;
    }
  }

  /// Enhanced pick and upload method (legacy support)
  Future<String?> pickAndUploadFile(String folderName, {bool isProfileImage = false}) async {
    if (kIsWeb) {
      await pickImageWeb(isProfileImage: isProfileImage);
    } else {
      await pickFileMobile(isProfileImage: isProfileImage);
    }

    if (isProfileImage && selectedProfileImage.value != null) {
      isUploading.value = true;
      try {
        final uploadPath = 'deliveryboy/$folderName/${isProfileImage ? 'profile.jpg' : 'document.jpg'}';
        final url = await uploadFileToFirebase(selectedProfileImage.value!, uploadPath);
        if (url != null && isProfileImage) {
          profileImageUrl.value = url;
        }
        return url;
      } catch (e) {
        Get.snackbar("Error", "File upload failed: $e");
        return null;
      } finally {
        isUploading.value = false;
      }
    }
    return null;
  }

  /// Main file picker entry points
  Future<void> pickProfileImage() async {
    if (kIsWeb) {
      await pickImageWeb(isProfileImage: true);
    } else {
      await pickFileMobile(isProfileImage: true);
    }
  }

  Future<void> pickDocument(String documentType) async {
    if (kIsWeb) {
      await pickImageWeb(isProfileImage: false);
    } else {
      await pickFileMobile(isProfileImage: false);
    }
  }

  @override
  void onClose() {
    // Dispose all controllers
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    whatsappController.dispose();
    addressController.dispose();
    drivingLicenseController.dispose();
    emergencyContact1Controller.dispose();
    emergencyContact2Controller.dispose();
    aadharController.dispose();
    panController.dispose();
    accountNoController.dispose();
    ifscController.dispose();
    upiController.dispose();
    zoneIdController.dispose();
    aadharUrlController.dispose();
    panUrlController.dispose();
    dlUrlController.dispose();
    bankPassbookUrlController.dispose();
    super.onClose();
  }
}