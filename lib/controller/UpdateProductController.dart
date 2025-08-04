import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UpdateProductController extends GetxController {
  final String productId;
  UpdateProductController(this.productId);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observables
  var productStatus = "Paused".obs;
  var foodType = "Veg".obs;
  var mainCategory = "Food".obs;
  var selectedSubcategory = "".obs;
  var selectedImageUrl = "".obs;

  // Image picking
  Rx<XFile?> selectedImage = Rx<XFile?>(null);
  final ImagePicker _picker = ImagePicker();

  // Subcategories example list
  List<String> subcategories = ['Tiffin',
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
    'Chicken',];

  // Text controllers
  TextEditingController productName = TextEditingController();
  TextEditingController productPrice = TextEditingController();
  TextEditingController yourPrice = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController productQty = TextEditingController();
  TextEditingController shopId = TextEditingController();
  TextEditingController shopName = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProductData();
  }

  Future<void> fetchProductData() async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();

      if (doc.exists) {
        final data = doc.data()!;

        productName.text = data['productName'] ?? '';
        productPrice.text = data['productPrice']?.toString() ?? '';
        yourPrice.text = data['yourprice']?.toString() ?? '';
        description.text = data['description'] ?? '';
        productQty.text = data['productQty']?.toString() ?? '';
        shopId.text = data['shopId'] ?? '';
        shopName.text = data['shopName'] ?? '';

        // Add Pending status option if exists, else default to Paused
        final status = data['productStatus'] ?? 'Paused';
        if (['Paused', 'Visible', 'Pending'].contains(status)) {
          productStatus.value = status;
        } else {
          productStatus.value = 'Paused';
        }

        foodType.value = data['foodType'] ?? 'Veg';
        mainCategory.value = data['mainCategory'] ?? 'Food';
        selectedSubcategory.value = data['subCategory'] ?? '';
        selectedImageUrl.value = data['imageUrl'] ?? '';
      }
    } catch (e) {
      print("Error fetching product: $e");
    }
  }


  Future<void> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        selectedImage.value = pickedFile;
        // If you want, clear old image URL when new image selected
        selectedImageUrl.value = '';
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> updateProduct() async {
    try {
      String imageUrlToSave = selectedImageUrl.value;

      // TODO: If you want to upload new image to storage and get URL, do it here
      // if (selectedImage.value != null) { upload image and assign imageUrlToSave = new url }

      await _firestore.collection('products').doc(productId).update({
        'name': productName.text,
        'price': double.tryParse(productPrice.text) ?? 0,
        'yourPrice': double.tryParse(yourPrice.text) ?? 0,
        'description': description.text,
        'quantity': int.tryParse(productQty.text) ?? 0,
        'status': productStatus.value,
        'foodType': foodType.value,
        'mainCategory': mainCategory.value,
        'subCategory': selectedSubcategory.value,
        'shopId': shopId.text,
        'shopName': shopName.text,
        'imageUrl': imageUrlToSave,
      });

      Get.snackbar("Success", "Product updated successfully",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to update product",
          backgroundColor: Colors.red, colorText: Colors.white);
      print("Update product error: $e");
    }
  }

  @override
  void onClose() {
    productName.dispose();
    productPrice.dispose();
    yourPrice.dispose();
    description.dispose();
    productQty.dispose();
    shopId.dispose();
    shopName.dispose();
    super.onClose();
  }
}
