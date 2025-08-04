import 'dart:convert';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/product.dart';

class ProductController extends GetxController {
  var selectedTab = 0.obs;
  var products = <Product>[].obs;
  var filteredProducts = <Product>[].obs;

  var searchController = TextEditingController();

  // Zone data
  List<int> zonePincodes = [];
  List<LatLng> zonePoints = [];

  @override
  void onInit() {
    super.onInit();
    loadZoneDataAndProducts();
    searchController.addListener(() {
      applySearchFilter(searchController.text);
    });
  }

  /// Load zone data first, then fetch products by zone
  Future<void> loadZoneDataAndProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final zoneJson = prefs.getString('zoneData');

      if (zoneJson == null) {
        print("⚠️ No zone data found in SharedPreferences");
        return;
      }

      final zoneData = jsonDecode(zoneJson);
      _parseZoneData(zoneData);

      await fetchProductsByZone();
    } catch (e) {
      print("Error loading zone data: $e");
    }
  }

  /// Fetch products belonging to shops inside the zone
  Future<void> fetchProductsByZone() async {
    try {
      // 1. Get zoneId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final zoneJson = prefs.getString('zoneData');
      if (zoneJson == null) {
        print("⚠️ No zone data in SharedPreferences");
        return;
      }

      final zoneData = jsonDecode(zoneJson);
      final zoneId = zoneData['zoneId'];

      if (zoneId == null || zoneId.isEmpty) {
        print("⚠️ zoneId missing in zoneData");
        return;
      }

      print("🔍 Current Zone ID: $zoneId");

      // 2. Fetch products filtered by zoneId and productStatus 'accepted'
      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('zoneId', isEqualTo: zoneId)
          .where('productStatus', isEqualTo: 'visible')
          .get();

      // --- DEBUGGING ---
      print("🔥 Total products fetched for this zone: ${productSnapshot.docs.length}");

      // Print names and IDs of all products fetched
      for (var doc in productSnapshot.docs) {
        final data = doc.data();
        final productName = data['productName'] ?? data['name'] ?? 'Unnamed';

        print("➡️ Product: $productName | ID: ${doc.id}");
      }


      // 3. Map data to Product model
      products.assignAll(
        productSnapshot.docs
            .map((doc) => Product.fromFirestore(doc.data(), doc.id))
            .toList(),
      );

      filteredProducts.assignAll(products);

      // --- DEBUGGING ---
      print("✅ Final products list count after filtering: ${products.length}");
    } catch (e) {
      print("❌ Error fetching products by zoneId: $e");
    }
  }




  /// Search filter
  void applySearchFilter(String query) {
    if (query.isEmpty) {
      filteredProducts.assignAll(products);
    } else {
      filteredProducts.assignAll(products.where((product) =>
      product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.id.toLowerCase().contains(query.toLowerCase())));
    }
  }

  /// Toggle product status between Live and Paused
  Future<void> toggleLiveStatus(int index) async {
    try {
      final product = filteredProducts[index];

      // Flip local boolean
      bool newIsLive = !product.isLive;
      String newStatus = newIsLive ? "Live" : "Paused";

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update({'productStatus': newStatus});

      // Update locally
      product.isLive = newIsLive;

      // Sync with main products list
      int originalIndex = products.indexWhere((p) => p.id == product.id);
      if (originalIndex != -1) {
        products[originalIndex].isLive = newIsLive;
      }

      update();

      Get.snackbar(
        "Success",
        "Product status updated to $newStatus",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update product status: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  // --- Zone logic same as shops ---
  void _parseZoneData(Map<String, dynamic> zoneData) {
    zonePincodes = (zoneData['pincodes'] ?? [])
        .map<int>((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
        .toList();

    zonePoints = (zoneData['zonePoints'] as List)
        .map((p) => LatLng(
      (p['latitude'] ?? 0).toDouble(),
      (p['longitude'] ?? 0).toDouble(),
    ))
        .toList();

    print("✅ Zone pincodes: $zonePincodes");
    print("✅ Zone points count: ${zonePoints.length}");
  }

  bool _isShopInZone(Map<String, dynamic> data) {
    final lat = (data['location']?['latitude'] ?? 0).toDouble();
    final lng = (data['location']?['longitude'] ?? 0).toDouble();

    final isInPolygon = _isPointInPolygon(LatLng(lat, lng), zonePoints);
    final shopPincode = _extractPincode(data['address']);
    final isPincodeMatch =
    zonePincodes.map((e) => e.toString()).contains(shopPincode);

    if (zonePoints.isEmpty) return isPincodeMatch;

    return isInPolygon || isPincodeMatch;
  }

  String _extractPincode(String? address) {
    if (address == null) return '';
    final regex = RegExp(r'PIN[:\s]+(\d{3,6})');
    final match = regex.firstMatch(address);
    return match?.group(1) ?? '';
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.isEmpty) return false;
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      if (_rayCastIntersect(point, polygon[j], polygon[j + 1])) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1;
  }

  bool _rayCastIntersect(LatLng point, LatLng vertA, LatLng vertB) {
    final px = point.latitude;
    final py = point.longitude;
    final ax = vertA.latitude;
    final ay = vertA.longitude;
    final bx = vertB.latitude;
    final by = vertB.longitude;

    return ((ay > py) != (by > py)) &&
        (px < (bx - ax) * (py - ay) / (by - ay + 0.0) + ax);
  }
}


