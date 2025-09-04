import 'dart:typed_data';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// Only import dart:html when on web
import 'dart:html' as html show FileUploadInputElement, FileReader, Blob, File;

class ProfileEditController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  var profileImage = ''.obs; // URL from Firestore or uploaded image URL
  var selectedImage = Rx<XFile?>(null); // Selected image file
  var isUploading = false.obs;

  String? sellerId; // Store current seller id for update

  @override
  void onInit() {
    super.onInit();
    testFirebaseStorageConnection();
  }

  // Test Firebase Storage connection
  Future<void> testFirebaseStorageConnection() async {
    try {
      print("Testing Firebase Storage connection for profiles...");
      final ref = FirebaseStorage.instance.ref().child('test/profile-connection-test.txt');
      await ref.putString('Firebase Storage working for profiles!');
      print("Firebase Storage connection successful for profiles");
    } catch (e) {
      print("Firebase Storage test failed for profiles: $e");
      Get.snackbar(
        "Storage Warning",
        "Firebase Storage connection issue. Profile images may not upload properly.",
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Web-specific image picker
  Future<void> pickImageWeb() async {
    if (!kIsWeb) return;

    try {
      html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
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
              "Please select an image smaller than 5MB. Current size: ${(file.size / 1024 / 1024).toStringAsFixed(1)}MB",
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: Duration(seconds: 3),
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }

          // Create XFile-like object for compatibility
          final bytes = await _readFileAsBytes(file);
          final tempXFile = XFile.fromData(bytes, name: file.name);

          selectedImage.value = tempXFile;
          print("Profile image selected: ${file.name} (${(file.size / 1024).toStringAsFixed(1)} KB)");

          Get.snackbar(
            "Success",
            "Profile image selected: ${file.name}",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      });
    } catch (e) {
      print("Error picking image: $e");
      Get.snackbar(
        "Error",
        "Failed to pick image: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Mobile/Desktop image picker
  Future<void> pickImageMobile() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        const maxSize = 5 * 1024 * 1024; // 5MB limit

        if (bytes.length > maxSize) {
          Get.snackbar(
            "File Too Large",
            "Please select an image smaller than 5MB. Current size: ${(bytes.length / 1024 / 1024).toStringAsFixed(1)}MB",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        selectedImage.value = pickedFile;
        print("Profile image selected: ${pickedFile.name} (${(bytes.length / 1024).toStringAsFixed(1)} KB)");

        Get.snackbar(
          "Success",
          "Profile image selected: ${pickedFile.name}",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Error picking image: $e");
      Get.snackbar(
        "Error",
        "Failed to pick image: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Main image picker method
  Future<void> pickProfileImage() async {
    if (kIsWeb) {
      await pickImageWeb();
    } else {
      await pickImageMobile();
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

  // Firebase Storage upload method
  Future<String?> uploadProfileImage() async {
    if (selectedImage.value == null) return null;

    try {
      print("Starting profile image upload to Firebase Storage...");
      isUploading.value = true;

      final Uint8List imageBytes = await selectedImage.value!.readAsBytes();
      print("Image size: ${(imageBytes.length / 1024).toStringAsFixed(1)} KB");

      final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String uploadPath = 'profiles/$fileName';

      final Reference storageRef = FirebaseStorage.instance.ref().child(uploadPath);

      UploadTask uploadTask;
      if (kIsWeb) {
        // Use blob upload for web
        final html.Blob blob = html.Blob([imageBytes]);
        uploadTask = storageRef.putBlob(blob);
      } else {
        // Use data upload for mobile/desktop
        uploadTask = storageRef.putData(
          imageBytes,
          SettableMetadata(
            contentType: 'image/jpeg',
            cacheControl: 'public, max-age=3600',
          ),
        );
      }

      final TaskSnapshot snapshot = await uploadTask.timeout(
        Duration(seconds: 60),
        onTimeout: () {
          uploadTask.cancel();
          throw TimeoutException('Upload timeout after 60 seconds', Duration(seconds: 60));
        },
      );

      final String downloadURL = await snapshot.ref.getDownloadURL();
      print("Profile image upload successful: $downloadURL");

      return downloadURL;
    } catch (e) {
      print("Profile image upload failed: $e");
      throw Exception("Failed to upload profile image: ${e.toString()}");
    } finally {
      isUploading.value = false;
    }
  }

  // Call this to load seller data into form for editing
  void loadSellerData(String id) async {
    sellerId = id;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        usernameController.text = data['name'] ?? '';
        phoneController.text = data['phone'] ?? '';
        emailController.text = data['email'] ?? '';
        profileImage.value = data['imageUrl'] ?? '';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load seller data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  // Clear form for adding new seller
  void clearForm() {
    sellerId = null;
    usernameController.clear();
    phoneController.clear();
    emailController.clear();
    profileImage.value = '';
    selectedImage.value = null;
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) return;

    isUploading.value = true;

    try {
      String imageUrl = profileImage.value; // Start with existing image URL

      // Upload new image if selected
      if (selectedImage.value != null) {
        try {
          final uploadedUrl = await uploadProfileImage();
          if (uploadedUrl != null) {
            imageUrl = uploadedUrl;
            profileImage.value = uploadedUrl; // Update the observable
          }
        } catch (imageError) {
          print("Image upload failed: $imageError");

          // Ask user if they want to continue without image
          final bool? continueWithoutImage = await Get.dialog<bool>(
            AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 28),
                  SizedBox(width: 12),
                  Expanded(child: Text("Image Upload Failed")),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Failed to upload profile image:",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      imageError.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[600],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text("Would you like to save the profile without updating the image?"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Continue Without Image"),
                ),
              ],
            ),
          );

          if (continueWithoutImage != true) {
            return;
          }
        }
      }

      final data = {
        'name': usernameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
        'platform': kIsWeb ? 'web' : 'mobile',
        'uploadMethod': selectedImage.value != null ? 'firebase_storage' : 'existing',
      };

      if (sellerId != null) {
        // Update existing seller
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
        // Add new seller
        data['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('users').add(data);
        Get.snackbar(
          'Success',
          'Seller added successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }

      await Future.delayed(Duration(milliseconds: 300));
      clearForm();
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
    } finally {
      isUploading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
}