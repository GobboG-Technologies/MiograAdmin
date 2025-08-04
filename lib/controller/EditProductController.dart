import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
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

  // ✅ FIXED: Subcategory handling
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

  /// Pick image from gallery (Web Compatible)
  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print("Picked image path: ${pickedFile.path}");
        selectedImage.value = pickedFile;

        Get.snackbar(
          "Success",
          "Image selected successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 1),
        );
      } else {
        print("No image was selected");
        Get.snackbar(
            "No Selection",
            "Please select an image from gallery",
            backgroundColor: Colors.orange,
            colorText: Colors.white
        );
      }
    } catch (e) {
      print("Error picking image: $e");
      Get.snackbar(
          "Error",
          "Failed to pick image: $e",
          backgroundColor: Colors.red,
          colorText: Colors.white
      );
    }
  }

  /// Upload product to Firestore (Web Compatible)
  Future<void> addProductToFirestore() async {
    try {
      // Validation: ensure required fields are filled including selected shop
      if (productName.text.trim().isEmpty ||
          productPrice.text.trim().isEmpty ||
          shopId.text.trim().isEmpty ||
          shopName.text.trim().isEmpty) {
        Get.snackbar(
          "Validation",
          "Please fill in required fields including selecting a shop",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Fetch zoneId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final zoneJson = prefs.getString('zoneData');
      String zoneId = '';

      if (zoneJson != null) {
        final zoneData = jsonDecode(zoneJson);
        zoneId = zoneData['zoneId'] ?? '';
      }

      // Show loading dialog
      Get.dialog(
        Center(
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
                Text("Adding product...", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      String imageUrl = '';

      if (selectedImage.value != null) {
        try {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

          final storage = FirebaseStorage.instanceFor(
            bucket: 'migora-f8f57.appspot.com',
          );

          final ref = storage.ref().child('product_images/$fileName');

          TaskSnapshot snapshot;

          if (kIsWeb) {
            final bytes = await selectedImage.value!.readAsBytes();
            snapshot = await ref.putData(bytes);
            print("Web: Uploading ${bytes.length} bytes");
          } else {
            final file = File(selectedImage.value!.path);
            if (await file.exists()) {
              snapshot = await ref.putFile(file);
              print("Mobile: Uploading file from ${file.path}");
            } else {
              throw Exception("File does not exist: ${selectedImage.value!.path}");
            }
          }

          if (snapshot.state == TaskState.success) {
            imageUrl = await snapshot.ref.getDownloadURL();
            print("Image uploaded successfully: $imageUrl");
          } else {
            throw Exception("Upload failed: ${snapshot.state}");
          }
        } catch (e) {
          Get.back(); // Close loading dialog
          print("Image upload error: $e");
          Get.snackbar("Image Upload Failed", "$e",
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
      }

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
        'zoneId': zoneId, // <-- added zoneId
        'productStatus': productStatus.value,
        'foodType': foodType.value,
        'mainCategory': mainCategory.value,
        'subCategory': selectedSubcategory.value,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtFormatted': formattedDate,
      };

      print("Adding product data: $productData");

      await FirebaseFirestore.instance.collection('products').add(productData);

      Get.back(); // Close loading dialog

      Get.snackbar(
        "Success",
        "Product Added Successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clear form after successful submission
      clearForm();
    } catch (e) {
      Get.back(); // Close loading dialog
      print("Firestore upload error: $e");
      Get.snackbar(
        "Error",
        "Failed to add product: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  /// Get file extension from a file
  String _getFileExtension(File file) {
    final path = file.path;
    final extension = path.split('.').last;
    return extension.isNotEmpty ? '.${extension}' : '.jpg';
  }

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
    productStatus.value = 'Visible'; // or your default
    foodType.value = 'Veg'; // or your default
    mainCategory.value = 'Food'; // or your default
    selectedImage.value = null;
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


  Future<List<Map<String, dynamic>>> fetchShopsByZone(String zoneId) async {
    try {
      // Query shops by zoneId and status accepted
      final snapshot = await FirebaseFirestore.instance
          .collection('Shops')
          .where('zoneId', isEqualTo: zoneId)
          .where('status', isEqualTo: 'accepted')
          .get();

      // Map the data to required fields
      final shops = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'shopId': doc.id, // Firestore document ID
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
}