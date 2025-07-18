import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditProductController extends GetxController {
  var selectedImage = Rx<XFile?>(null);
  var productStatus = 'Visible'.obs;
  var foodType = 'Veg'.obs;
  var mainCategory = 'Food'.obs;

  // Form controllers
  TextEditingController productName = TextEditingController();
  TextEditingController productPrice = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController productQty = TextEditingController();
  TextEditingController sellerId = TextEditingController();
  TextEditingController businesId = TextEditingController();
  TextEditingController shopId = TextEditingController();
  TextEditingController shopName = TextEditingController();
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
            // ✅ For web platform, upload bytes
            final bytes = await selectedImage.value!.readAsBytes();
            snapshot = await ref.putData(bytes);
            print("Web: Uploading ${bytes.length} bytes");
          } else {
            // ✅ For mobile platforms, upload file
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

      // ✅ FIXED: Ensure proper data types
      final Map<String, dynamic> productData = {
        'name': productName.text.trim(),
        'price': double.tryParse(productPrice.text) ?? 0.0,
        'yourPrice': double.tryParse(yourprice.text) ?? 0.0,
        'description': description.text.trim(),
        'quantity': int.tryParse(productQty.text) ?? 0,
        'sellerId': sellerId.text.trim(),
        'businessId': businesId.text.trim(),
        'shopId': shopId.text.trim(),
        'shopName': shopName.text.trim(),
        'status': productStatus.value,
        'foodType': foodType.value,
        'mainCategory': mainCategory.value,
        'subCategory': selectedSubcategory.value,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtFormatted': formattedDate,
      };

      print("Adding product data: $productData");

      await FirebaseFirestore.instance
          .collection('products')
          .add(productData);

      Get.back(); // Close loading dialog

      Get.snackbar(
          "Success",
          "Product Added Successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white
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
          colorText: Colors.white
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
    selectedImage.value = null;
    productName.clear();
    productPrice.clear();
    yourprice.clear();
    description.clear();
    productQty.clear();
    sellerId.clear();
    businesId.clear();
    shopId.clear();
    shopName.clear();
    productStatus.value = 'Visible';
    foodType.value = 'Veg';
    mainCategory.value = 'Food';
    selectedSubcategory.value = '';
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