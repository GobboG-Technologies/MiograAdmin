import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'shopController.dart'; // Import ShopController to access the shops list

class UpdateProductController extends GetxController {
  final String productId;
  UpdateProductController(this.productId);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Get instance of ShopController to access the list of shops
  final ShopController _shopController = Get.find<ShopController>();

  // Observables
  var isLoading = true.obs; // Added for initial loading state
  var productStatus = "Paused".obs;
  var foodType = "Veg".obs;
  var mainCategory = "Food".obs;
  var selectedSubcategory = "".obs; // Initialize as empty string
  var selectedImageUrl = "".obs;
  var selectedShopId = "".obs; // To hold the ID of the selected shop

  // Image picking
  Rx<XFile?> selectedImage = Rx<XFile?>(null);
  final ImagePicker _picker = ImagePicker();

  // Subcategories example list
  List<String> subcategories = [
    'Tiffin', 'chinese', 'Tea & coffe', 'cake', 'Burger', 'Beef & Mutton',
    'Biriyani', 'Pizza', 'Meals', 'Ice Cream & Shakes', 'Bakery', 'Chicken',
  ];

  // Text controllers
  TextEditingController productName = TextEditingController();
  TextEditingController productPrice = TextEditingController();
  TextEditingController yourPrice = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController productQty = TextEditingController();
  // Removed shopId and shopName text controllers

  @override
  void onInit() {
    super.onInit();
    fetchProductData();
  }

  Future<void> fetchProductData() async {
    try {
      isLoading.value = true; // Set loading to true
      final doc = await _firestore.collection('products').doc(productId).get();

      if (doc.exists) {
        final data = doc.data()!;

        productName.text = data['productName'] ?? '';
        productPrice.text = data['productPrice']?.toString() ?? '';
        yourPrice.text = data['yourprice']?.toString() ?? '';
        description.text = data['description'] ?? '';
        productQty.text = data['productQty']?.toString() ?? '';

        // Set the initial shop from the fetched data
        selectedShopId.value = data['shopId']?.toString() ?? ''; // Ensure it's a string

        final status = data['productStatus'] ?? 'Paused';
        productStatus.value = ['Paused', 'Visible', 'Pending'].contains(status) ? status : 'Paused';

        foodType.value = data['foodType'] ?? 'Veg';
        mainCategory.value = data['mainCategory'] ?? 'Food';
        selectedSubcategory.value = data['subCategory'] ?? '';
        selectedImageUrl.value = data['imageUrl'] ?? '';
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch product data.",
          backgroundColor: Colors.red, colorText: Colors.white);
      print("Error fetching product: $e");
    } finally {
      isLoading.value = false; // Set loading to false after data is fetched or error occurs
    }
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        selectedImage.value = pickedFile;
        selectedImageUrl.value = ''; // Clear old image URL when new image selected
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> updateProduct() async {
    if (selectedShopId.value.isEmpty) {
      Get.snackbar("Error", "Please select a shop.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      String imageUrlToSave = selectedImageUrl.value;

      // TODO: Implement image upload logic if a new image is selected
      // if (selectedImage.value != null) {
      //   // 1. Upload selectedImage.value.path to your storage (e.g., Firebase Storage)
      //   // 2. Get the download URL
      //   // 3. Assign it to imageUrlToSave
      // }

      // Find the shop name from the ShopController's list
      // Ensure shops list is not empty before attempting to find
      String shopName = 'Unknown Shop';
      if (_shopController.shops.isNotEmpty) {
        final selectedShop = _shopController.shops.firstWhere(
              (shop) => shop['id'].toString() == selectedShopId.value, // Compare string IDs
          orElse: () => {'name': 'Unknown Shop'},
        );
        shopName = selectedShop['name'] ?? 'Unknown Shop';
      }


      await _firestore.collection('products').doc(productId).update({
        'productName': productName.text,
        'productPrice': double.tryParse(productPrice.text) ?? 0,
        'yourprice': double.tryParse(yourPrice.text) ?? 0,
        'description': description.text,
        'productQty': int.tryParse(productQty.text) ?? 0,
        'status': productStatus.value,
        'foodType': foodType.value,
        'mainCategory': mainCategory.value,
        'subCategory': selectedSubcategory.value,
        'shopId': selectedShopId.value, // Use the selected shop ID
        'shopName': shopName,         // Use the retrieved shop name
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
    super.onClose();
  }
}