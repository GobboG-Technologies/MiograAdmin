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

  // Cloud Function URL
  static const String CLOUD_FUNCTION_URL = 'https://us-central1-migora-f8f57.cloudfunctions.net/uploadProductImage';

  @override
  void onInit() {
    super.onInit();
    print("EditProductController initialized");

    Future.delayed(Duration(seconds: 2), () async {
      await testStorageMethod();
    });
  }

  // Platform detection helper
  bool _isDesktopPlatform() {
    return !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
  }

  // Test which upload method to use
  Future<void> testStorageMethod() async {
    try {
      final bool isDesktop = _isDesktopPlatform();

      if (isDesktop) {
        print("Desktop platform detected - will use Cloud Function for uploads");

        try {
          final response = await http.get(
            Uri.parse(CLOUD_FUNCTION_URL),
          ).timeout(Duration(seconds: 10));

          if (response.statusCode == 405 || response.statusCode == 200) {
            print("Cloud Function is reachable and ready");
            Get.snackbar(
              "Desktop Mode",
              "Cloud Function upload enabled",
              backgroundColor: Colors.blue[100],
              colorText: Colors.blue[800],
              duration: Duration(seconds: 3),
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        } catch (e) {
          print("Cloud Function not reachable: $e");
          Get.snackbar(
            "Limited Mode",
            "Cloud upload unavailable - you can add products without images",
            backgroundColor: Colors.orange[100],
            colorText: Colors.orange[800],
            duration: Duration(seconds: 4),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        print("Web/Mobile platform - using standard Firebase Storage");
        await testFirebaseStorage();
      }
    } catch (e) {
      print("Storage test failed: $e");
    }
  }

  // Test standard Firebase Storage
  Future<void> testFirebaseStorage() async {
    try {
      print("Testing Firebase Storage connection...");
      final ref = FirebaseStorage.instance.ref();
      print("Firebase Storage is ready");

      Get.snackbar(
        "Storage Ready",
        "Image upload is available",
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print("Firebase Storage test failed: $e");
    }
  }

  // Pick image from the source provided
  Future<void> pickImage(ImageSource source) async {
    if (_isDesktopPlatform() && source == ImageSource.camera) {
      Get.snackbar(
        "Unsupported Action",
        "Camera is not available on desktop platforms.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

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

  // Main upload method that chooses the right approach
  Future<String> uploadImage() async {
    if (selectedImage.value == null) return '';

    if (_isDesktopPlatform()) {
      return await uploadViaCloudFunction();
    } else {
      return await uploadViaFirebaseStorageWithTimeout();
    }
  }

  // Cloud Function upload method
  Future<String> uploadViaCloudFunction() async {
    if (selectedImage.value == null) return '';

    try {
      print("Starting Cloud Function upload...");

      final Uint8List imageBytes = await selectedImage.value!.readAsBytes();
      print("Image size: ${(imageBytes.length / 1024).toStringAsFixed(1)} KB");

      const maxSize = 5 * 1024 * 1024;
      if (imageBytes.length > maxSize) {
        throw Exception("Image too large. Maximum size is 5MB");
      }

      final String base64Image = base64Encode(imageBytes);
      final String fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';

      print("Uploading to Cloud Function: $CLOUD_FUNCTION_URL");

      final response = await http.post(
        Uri.parse(CLOUD_FUNCTION_URL),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'imageBase64': base64Image,
          'fileName': fileName,
          'productId': '',
        }),
      ).timeout(
        Duration(seconds: 120),
        onTimeout: () {
          throw Exception('Upload timeout - please check your connection');
        },
      );

      print("Cloud Function response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final String imageUrl = data['url'] ?? '';
          print("Cloud upload successful: $imageUrl");
          return imageUrl;
        } else {
          throw Exception(data['error'] ?? 'Upload failed');
        }
      } else {
        String errorMessage = 'Server error: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ?? errorMessage;
        } catch (e) {
          // Use default error message
        }
        throw Exception(errorMessage);
      }

    } catch (e) {
      print("Cloud function upload failed: $e");

      if (e.toString().contains('timeout')) {
        throw Exception("Upload timed out. Please check your internet connection.");
      } else if (e.toString().contains('SocketException')) {
        throw Exception("Network error. Please check your internet connection.");
      } else {
        throw Exception("Cloud upload failed: ${e.toString()}");
      }
    }
  }

  // Firebase Storage upload with timeout
  Future<String> uploadViaFirebaseStorageWithTimeout() async {
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

      final UploadTask uploadTask = storageRef.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=3600',
        ),
      );

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

      if (_isDesktopPlatform()) {
        print("Fallback: Trying cloud function after Firebase failure");
        return await uploadViaCloudFunction();
      }

      throw Exception("Storage upload failed: ${e.toString()}");
    }
  }

  // Standard Firebase Storage upload (legacy method)
  Future<String> uploadViaFirebaseStorage() async {
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

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadURL = await snapshot.ref.getDownloadURL();

      print("Firebase Storage upload successful: $downloadURL");
      return downloadURL;

    } catch (e) {
      print("Firebase Storage upload failed: $e");
      throw Exception("Storage upload failed: ${e.toString()}");
    }
  }

  // Add product to Firestore
  Future<void> addProductToFirestore() async {
    print("Starting product addition...");

    try {
      // Basic validation
      // if (productName.text.trim().isEmpty || productPrice.text.trim().isEmpty) {
      //   Get.snackbar(
      //     "Validation Error",
      //     "Please fill in Product Name and Price",
      //     backgroundColor: Colors.orange,
      //     colorText: Colors.white,
      //     snackPosition: SnackPosition.TOP,
      //   );
      //   return;
      // }

     // if (shopId.text.trim().isEmpty) {
      //   Get.snackbar(
      //     "Validation Error",
      //     "Please select a shop",
      //     backgroundColor: Colors.orange,
      //     colorText: Colors.white,
      //     snackPosition: SnackPosition.TOP,
      //   );
      //   return;
      // }`

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

      if (_isDesktopPlatform() && selectedImage.value != null) {
        loadingTitle = "Uploading via Cloud Function...";
        loadingMessage = "This may take up to 2 minutes for large images";
      } else if (selectedImage.value != null) {
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
        'platform': _getPlatformName(),
        'status': 'Paused',
        'uploadMethod': imageUrl.isNotEmpty ? _getUploadMethod() : 'none',
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

  // Helper methods
  String _getPlatformName() {
    if (kIsWeb) return 'web';
    if (!kIsWeb) {
      if (Platform.isWindows) return 'windows';
      if (Platform.isLinux) return 'linux';
      if (Platform.isMacOS) return 'macos';
      if (Platform.isAndroid) return 'android';
      if (Platform.isIOS) return 'ios';
    }
    return 'unknown';
  }

  String _getUploadMethod() {
    return _isDesktopPlatform() ? 'cloud_function' : 'firebase_storage';
  }

  String _getPlatformMessage() {
    if (_isDesktopPlatform()) {
      return "Using Cloud Function upload\nThis may take up to 2 minutes";
    } else {
      return "This may take a few moments";
    }
  }

  // Ensure connection stability
  Future<void> ensureConnectionStability() async {
    if (_isDesktopPlatform()) {
      print("Ensuring connection stability...");
      await Future.delayed(Duration(milliseconds: 500));

      try {
        await FirebaseFirestore.instance
            .collection('test')
            .doc('ping')
            .get(GetOptions(source: Source.server))
            .timeout(Duration(seconds: 5));
        print("Firebase connection stable");
      } catch (e) {
        print("Connection test failed: $e");
      }
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