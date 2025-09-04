import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html show FileUploadInputElement, FileReader, Blob, File;

class EditProductController extends GetxController {
  var selectedImage = Rx<XFile?>(null);
  var productStatus = 'visible'.obs;
  var foodType = 'Veg'.obs;
  var mainCategory = 'Food'.obs;
  var status = 'Paused'.obs;
  var shopId = TextEditingController();
  var shopName = TextEditingController();

  // Form controllers
  TextEditingController productName = TextEditingController();
  TextEditingController productPrice = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController productQty = TextEditingController();
  TextEditingController sellerId = TextEditingController();
  TextEditingController businesId = TextEditingController();
  TextEditingController yourprice = TextEditingController();

  var selectedSubcategory = ''.obs;

  final List<String> subcategories = [
    'Tiffin',
    'chinese',
    'Tea & coffe',
    'cake',
    'Burger',
    'Beef & Mutton',
    'Biriyani',
    'Pizza',
    'Meals',
    'Ice Cream & Shakes',
    'Bakery',
    'Chicken',
  ];

  @override
  void onInit() {
    super.onInit();
    print("EditProductController initialized");
    Future.delayed(Duration(seconds: 2), () async {
      await testStorageMethod();
    });
  }

  // Test Firebase Storage (we know this works!)
  Future<void> testStorageMethod() async {
    try {
      print("Testing Firebase Storage connection...");

      // Quick test to verify Firebase Storage works
      final ref = FirebaseStorage.instance.ref().child('test/connection-test.txt');
      await ref.putString('Firebase Storage is working!');
      print("Firebase Storage connection successful");

      Get.snackbar(
        "Storage Ready",
        "Firebase Storage is working - Image upload available!",
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print("Firebase Storage test failed: $e");
      Get.snackbar(
        "Storage Issue",
        "Firebase Storage connection failed. Images may not upload properly.",
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Web-specific image picker
  Future<void> pickImageWeb() async {
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
            );
            return;
          }

          // Create XFile-like object for compatibility
          final bytes = await _readFileAsBytes(file);
          final tempXFile = XFile.fromData(bytes, name: file.name);

          selectedImage.value = tempXFile;
          print("Image selected: ${file.name} (${(file.size / 1024).toStringAsFixed(1)} KB)");

          Get.snackbar(
            "Success",
            "Image selected: ${file.name}",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
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
      );
    }
  }

  // Helper method to read file bytes for web
  Future<Uint8List> _readFileAsBytes(html.File file) async {
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

  // Mobile/Desktop image picker (existing functionality)
  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
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
          );
          return;
        }

        print("Image selected: ${pickedFile.name} (${(bytes.length / 1024).toStringAsFixed(1)} KB)");
        selectedImage.value = pickedFile;

        Get.snackbar(
          "Success",
          "Image selected: ${pickedFile.name}",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      print("Error picking image: $e");
      Get.snackbar(
        "Error",
        "Failed to pick image: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Firebase Storage upload (this is the method that works!)
  Future<String> uploadImageToFirebase() async {
    if (selectedImage.value == null) return '';

    try {
      print("Starting Firebase Storage upload...");

      final Uint8List imageBytes = await selectedImage.value!.readAsBytes();
      print("Image size: ${(imageBytes.length / 1024).toStringAsFixed(1)} KB");

      const maxSize = 5 * 1024 * 1024;
      if (imageBytes.length > maxSize) {
        throw Exception("Image too large. Maximum size is 5MB");
      }

      final String fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('products')
          .child(fileName);

      print("Upload path: products/$fileName");

      final UploadTask uploadTask = storageRef.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=3600',
        ),
      );

      // Add timeout for upload
      final TaskSnapshot snapshot = await uploadTask.timeout(
        Duration(seconds: 60),
        onTimeout: () {
          uploadTask.cancel();
          throw TimeoutException('Upload timeout after 60 seconds', Duration(seconds: 60));
        },
      );

      final String downloadURL = await snapshot.ref.getDownloadURL();
      print("Firebase Storage upload successful: $downloadURL");
      return downloadURL;

    } catch (e) {
      print("Firebase Storage upload failed: $e");
      throw Exception("Firebase Storage upload failed: ${e.toString()}");
    }
  }

  // Web-specific upload using blob (for better web compatibility)
  Future<String> uploadImageWebBlob() async {
    if (selectedImage.value == null) return '';

    try {
      print("Starting web blob upload to Firebase Storage...");

      final Uint8List imageBytes = await selectedImage.value!.readAsBytes();
      print("Image size: ${(imageBytes.length / 1024).toStringAsFixed(1)} KB");

      final String fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('products')
          .child(fileName);

      // Create blob for web upload
      final html.Blob blob = html.Blob([imageBytes]);
      final UploadTask uploadTask = storageRef.putBlob(blob);

      final TaskSnapshot snapshot = await uploadTask.timeout(
        Duration(seconds: 60),
        onTimeout: () {
          uploadTask.cancel();
          throw TimeoutException('Upload timeout after 60 seconds', Duration(seconds: 60));
        },
      );

      final String downloadURL = await snapshot.ref.getDownloadURL();
      print("Web blob upload successful: $downloadURL");
      return downloadURL;

    } catch (e) {
      print("Web blob upload failed: $e");
      throw Exception("Web upload failed: ${e.toString()}");
    }
  }

  // Main upload method that chooses the best approach
  Future<String> uploadImage() async {
    if (selectedImage.value == null) return '';

    if (kIsWeb) {
      // Use blob upload for web (better compatibility)
      return await uploadImageWebBlob();
    } else {
      // Use standard upload for mobile/desktop
      return await uploadImageToFirebase();
    }
  }

  // Add product to Firestore
  Future<void> addProductToFirestore() async {
    print("Starting product addition...");

    try {
      // Basic validation
      if (productName.text.trim().isEmpty || productPrice.text.trim().isEmpty) {
        Get.snackbar(
          "Validation Error",
          "Please fill in Product Name and Price",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // if (shopId.text.trim().isEmpty) {
      //   Get.snackbar(
      //     "Validation Error",
      //     "Please select a shop",
      //     backgroundColor: Colors.orange,
      //     colorText: Colors.white,
      //     snackPosition: SnackPosition.TOP,
      //   );
      //   return;
      // }

      // Get zone data
      final prefs = await SharedPreferences.getInstance();
      final zoneJson = prefs.getString('zoneData');
      String zoneId = '';
      if (zoneJson != null) {
        final zoneData = jsonDecode(zoneJson);
        zoneId = zoneData['zoneId'] ?? '';
      }

      // Show loading dialog
      String loadingTitle = "Adding Product...";
      String loadingMessage = "Please wait...";

      if (selectedImage.value != null) {
        loadingTitle = "Uploading Image...";
        loadingMessage = "This may take a few moments";
      }

      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(24),
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.purple[900],
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 20),
                    Text(
                      loadingTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[900],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      loadingMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      String imageUrl = '';

      // Upload image if selected
      if (selectedImage.value != null) {
        try {
          imageUrl = await uploadImage();
          print("Image uploaded successfully: $imageUrl");
        } catch (imageError) {
          print("Image upload failed: $imageError");

          if (Get.isDialogOpen == true) {
            Get.back();
          }

          final bool? continueWithoutImage = await Get.dialog<bool>(
            AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 28),
                  SizedBox(width: 12),
                  Expanded(child: Text("Image Upload Failed")),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Failed to upload image:",
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
                    Text("Would you like to add the product without the image?"),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[900],
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

          // Show loading again for saving without image
          Get.dialog(
            WillPopScope(
              onWillPop: () async => false,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.purple[900]),
                        SizedBox(height: 16),
                        Text("Saving product...", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            barrierDismissible: false,
          );
        }
      }

      // Save to Firestore
      print("Adding product to Firestore...");

      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final Map<String, dynamic> productData = {
        'productName': productName.text.trim(),
        'price': double.tryParse(productPrice.text) ?? 0.0,
        'yourPrice': double.tryParse(yourprice.text) ?? 0.0,
        'description': description.text.trim(),
        'quantity': int.tryParse(productQty.text) ?? 0,
        'sellerId': sellerId.text.trim(),
        'businessId': businesId.text.trim(),
        'shopId': shopId.text.trim(),
        'shopName': shopName.text.trim(),
        'zoneId': zoneId,
        'productStatus': productStatus.value,
        'foodType': foodType.value,
        'mainCategory': mainCategory.value,
        'subCategory': selectedSubcategory.value,
        'imageUrl': imageUrl,
        'needsImage': imageUrl.isEmpty,
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtFormatted': formattedDate,
        'platform': kIsWeb ? 'web' : 'mobile',
        'status': 'Paused',
        'uploadMethod': imageUrl.isNotEmpty ? 'firebase_storage' : 'none',
      };

      final DocumentReference docRef = await FirebaseFirestore.instance
          .collection('products')
          .add(productData);

      await docRef.update({'documentId': docRef.id});

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      final bool hasImage = imageUrl.isNotEmpty;
      Get.snackbar(
        "Success!",
        "Product '${productName.text.trim()}' added successfully${hasImage ? ' with image' : ''}!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );

      clearForm();
      print("Product added successfully ${hasImage ? 'with image' : 'without image'}");

    } catch (e, stackTrace) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      print("Error adding product: $e");

      String userFriendlyError = "Failed to add product";

      if (e.toString().contains('timeout')) {
        userFriendlyError = "Upload timed out. Please check your internet connection.";
      } else if (e.toString().contains('Network')) {
        userFriendlyError = "Network error. Please check your internet connection.";
      } else if (e.toString().contains('too large')) {
        userFriendlyError = "Image is too large. Please select an image smaller than 5MB.";
      }

      Get.snackbar(
        "Upload Failed",
        userFriendlyError,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Clear form fields
  void clearForm() {
    productName.clear();
    productPrice.clear();
    yourprice.clear();
    description.clear();
    productQty.clear();
    sellerId.clear();
    businesId.clear();
    shopId.clear();
    shopName.clear();
    selectedSubcategory.value = '';
    productStatus.value = 'visible';
    foodType.value = 'Veg';
    mainCategory.value = 'Food';
    selectedImage.value = null;
  }

  // Fetch shops by zone
  Future<List<Map<String, dynamic>>> fetchShopsByZone(String zoneId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Shops')
          .where('zoneId', isEqualTo: zoneId)
          .where('status', isEqualTo: 'accepted')
          .get();

      final shops = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'shopId': doc.id,
          'shopName': data['name'] ?? '',
          'address': data['address'] ?? '',
          'image': data['profileImage'] ?? '',
        };
      }).toList();

      return shops;
    } catch (e) {
      print("Error fetching shops: $e");
      return [];
    }
  }

  @override
  void onClose() {
    productName.dispose();
    productPrice.dispose();
    yourprice.dispose();
    description.dispose();
    productQty.dispose();
    sellerId.dispose();
    businesId.dispose();
    shopId.dispose();
    shopName.dispose();
    super.onClose();
  }
}