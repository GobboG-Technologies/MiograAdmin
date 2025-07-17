import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Models/product.dart';

class ProductController extends GetxController {
  var selectedTab = 0.obs;
  var products = <Product>[].obs;
  var filteredProducts = <Product>[].obs;

  var searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    searchController.addListener(() {
      applySearchFilter(searchController.text);
    });
  }

  void fetchProducts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('timestamp', descending: true)
          .get();

      var fetchedProducts = snapshot.docs.map((doc) {
        return Product.fromFirestore(doc.data(), doc.id);
      }).toList();

      products.assignAll(fetchedProducts);
      filteredProducts.assignAll(fetchedProducts); // Initialize filtered list
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void applySearchFilter(String query) {
    if (query.isEmpty) {
      filteredProducts.assignAll(products);
    } else {
      filteredProducts.assignAll(products.where((product) =>
      product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.id.toLowerCase().contains(query.toLowerCase())));
    }
  }

  void toggleLiveStatus(int index) {
    products[index].isLive = !products[index].isLive;
    filteredProducts[index].isLive = products[index].isLive;
    update();
  }
}
