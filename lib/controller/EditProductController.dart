import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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



  /// Pick image from gallery
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print("Picked image path: ${pickedFile.path}");

      final file = File(pickedFile.path);
      if (await file.exists()) {
        selectedImage.value = pickedFile;
      } else {
        Get.snackbar("Error", "Selected file does not exist.",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      Get.snackbar("No image selected", "Please pick an image.",
          backgroundColor: Colors.orange, colorText: Colors.white);
    }
  }

  /// Upload product to Firestore
  Future<void> addProductToFirestore() async {
    try {
      String imageUrl = '';

      if (selectedImage.value != null) {
        try {
          final file = File(selectedImage.value!.path);
          final fileName = '${DateTime.now().millisecondsSinceEpoch}${_getFileExtension(file)}';

          final storage = FirebaseStorage.instanceFor(
            bucket: 'migora-f8f57.appspot.com',
          );

          final ref = storage.ref().child('product_images/$fileName');
          final TaskSnapshot snapshot = await ref.putFile(file);

          if (snapshot.state == TaskState.success) {
            imageUrl = await snapshot.ref.getDownloadURL();
            print("Image uploaded successfully: $imageUrl");
          } else {
            throw Exception("Upload failed: ${snapshot.state}");
          }
        } catch (e) {
          print("Image upload error: $e");
          Get.snackbar("Image Upload Failed", "$e",
              backgroundColor: Colors.red, colorText: Colors.white);
          return; // Don’t proceed to Firestore if image fails
        }
      }

      // ✅ Don't access selectedImage.value!.path if it's null
      if (selectedImage.value != null) {
        print("Selected file: ${selectedImage.value?.path}");
        print("File exists: ${await File(selectedImage.value!.path).exists()}");
      } else {
        print("No image selected.");
      }

      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await FirebaseFirestore.instance.collection('products').add({
        'name': productName.text,
        'price': double.tryParse(productPrice.text) ?? 0,
        'yourPrice': double.tryParse(yourprice.text) ?? 0,
        'description': description.text,
        'quantity': int.tryParse(productQty.text) ?? 0,
        'sellerId': sellerId.text,
        'businessId': businesId.text,
        'shopId': shopId.text,
        'shopName': shopName.text,
        'status': productStatus.value,
        'foodType': foodType.value,
        'mainCategory': mainCategory.value,
        'subCategory': selectedSubcategory.value,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.now(),
        'createdAtFormatted': formattedDate,
      });

      Get.snackbar("Success", "Product Added Successfully",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      print("Upload error: $e");
      Get.snackbar("Error", "Failed to add product: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }


  /// Get file extension from a file
  String _getFileExtension(File file) {
    final path = file.path;
    final extension = path.split('.').last;
    return extension.isNotEmpty ? '.${extension}' : '.jpg';
  }

  // Inside EditProductController
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

}
