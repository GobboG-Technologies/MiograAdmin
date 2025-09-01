import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../Models/product.dart';

class ProductController extends GetxController {
  var products = <Product>[].obs;
  var filteredProducts = <Product>[].obs;
  var searchController = TextEditingController();
  var hasPermission = false.obs;


  // Zone variables
  var zones = <Map<String, dynamic>>[].obs;
  var selectedZoneId = Rxn<String>();
  var selectedTab = 0.obs;

  List<int> zonePincodes = [];
  List<LatLng> zonePoints = [];

  @override
  void onInit() {
    super.onInit();
    _loadZoneDataAndProducts();
    searchController.addListener(() {
      applySearchFilter(searchController.text);
    });
  }

  /// Load zones from SharedPreferences and fetch products for selected zone
  Future<void> _loadZoneDataAndProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString('adminSession');
      if (sessionJson == null) return;

      final sessionData = jsonDecode(sessionJson);
      final List<dynamic> zonesData = sessionData['zonesData'] ?? [];
      zones.assignAll(zonesData.cast<Map<String, dynamic>>());

      // Default selected zone
      final primaryZoneId = sessionData['primaryZoneId'];
      if (primaryZoneId != null && zones.any((z) => z['zoneId'] == primaryZoneId)) {
        selectedZoneId.value = primaryZoneId;
      } else if (zones.isNotEmpty) {
        selectedZoneId.value = zones.first['zoneId'];
      }

      if (selectedZoneId.value != null) {
        await fetchProductsByZone(selectedZoneId.value!);
      }
    } catch (e) {
      print("❌ Error loading zones: $e");
    }
  }

  /// Fetch products filtered by selected zone
  Future<void> fetchProductsByZone([String? zoneId]) async {
    try {
      final id = zoneId ?? selectedZoneId.value;
      if (id == null) return;

      print("🔍 Checking zone permission for zoneId: '$id'");

      // Fetch the zone document
      final zoneDoc = await FirebaseFirestore.instance.collection('zone').doc(id).get();
      if (!zoneDoc.exists) {
        print("⚠️ Zone not found for ID: $id");
        products.clear();
        filteredProducts.clear();
        return;
      }

      final zoneData = zoneDoc.data() ?? {};
      print("📄 Zone data: $zoneData");

      final adminPermissions = zoneData['adminPermissions'];
      if (adminPermissions == null || adminPermissions is! Map) {
        print("⚠️ adminPermissions is missing or not a map.");
        products.clear();
        filteredProducts.clear();
        return;
      }

      bool productListEnabled = false;


      (adminPermissions as Map<String, dynamic>).forEach((adminId, perms) {
        if (perms is Map && perms['productList'] == true) {
          productListEnabled = true;
        }
      });

      if (!productListEnabled) {
        print("🚫 No admin has productList enabled for zone: $id");
        products.clear();
        filteredProducts.clear();
        return;
      } else {
        print("✅ productList is enabled. Fetching products...");
      }

      // Fetch products from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('zoneId', isEqualTo: id)
          .where('status', isEqualTo: 'accepted')
          .get();

      final fetchedProducts = snapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .toList();

      products.assignAll(fetchedProducts);
      filteredProducts.assignAll(fetchedProducts);

      print("✅ ${fetchedProducts.length} products loaded for zone $id");
    } catch (e) {
      print("❌ Error fetching products: $e");
    }
  }


  /// Zone selection changed
  Future<void> onZoneChanged(String? newZoneId) async {
    if (newZoneId == null || newZoneId == selectedZoneId.value) return;
    selectedZoneId.value = newZoneId;
    products.clear();
    filteredProducts.clear();
    await fetchProductsByZone(newZoneId);
  }

  /// Search filter
  void applySearchFilter(String query) {
    if (query.isEmpty) {
      filteredProducts.assignAll(products);
    } else {
      filteredProducts.assignAll(
        products.where((p) =>
        p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.id.toLowerCase().contains(query.toLowerCase())),
      );
    }
  }

  /// Toggle product Live/Offline
  Future<void> toggleLiveStatus(int index) async {
    try {
      final product = filteredProducts[index];
      bool newIsLive = !product.isLive;
      String newStatus = newIsLive ? "Live" : "Paused";

      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update({'productStatus': newStatus});

      product.isLive = newIsLive;
      int originalIndex = products.indexWhere((p) => p.id == product.id);
      if (originalIndex != -1) products[originalIndex].isLive = newIsLive;

      update();
      Get.snackbar("Success", "Product status updated to $newStatus",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to update product status: $e",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }


  /// Check if paymentUpdate is enabled for the selected zone
  Future<bool> canEditProduct() async {
    final zoneId = selectedZoneId.value;
    if (zoneId == null) return false;

    try {
      final zoneDoc = await FirebaseFirestore.instance.collection('zone').doc(zoneId).get();
      if (!zoneDoc.exists) return false;

      final zoneData = zoneDoc.data() ?? {};
      final adminPermissions = zoneData['adminPermissions'];
      if (adminPermissions == null || adminPermissions is! Map) return false;

      bool paymentUpdateEnabled = false;
      (adminPermissions as Map<String, dynamic>).forEach((adminId, perms) {
        if (perms is Map && perms['paymentUpdate'] == true) {
          paymentUpdateEnabled = true;
        }
      });

      return paymentUpdateEnabled;
    } catch (e) {
      print("❌ Error checking paymentUpdate permission: $e");
      return false;
    }
  }
  /// Check if productCreate is enabled for the selected zone
  Future<bool> canCreateProduct() async {
    final zoneId = selectedZoneId.value;
    if (zoneId == null) return false;

    try {
      final zoneDoc = await FirebaseFirestore.instance.collection('zone').doc(zoneId).get();
      if (!zoneDoc.exists) return false;

      final zoneData = zoneDoc.data() ?? {};
      final adminPermissions = zoneData['adminPermissions'];
      if (adminPermissions == null || adminPermissions is! Map) return false;

      bool productCreateEnabled = false;
      (adminPermissions as Map<String, dynamic>).forEach((adminId, perms) {
        if (perms is Map && perms['productCreate'] == true) {
          productCreateEnabled = true;
        }
      });

      return productCreateEnabled;
    } catch (e) {
      print("❌ Error checking productCreate permission: $e");
      return false;
    }
  }


}
