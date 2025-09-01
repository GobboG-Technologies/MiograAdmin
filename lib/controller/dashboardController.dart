import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardController extends GetxController {
  var selectedZoneId = Rxn<String>();
  var zones = <Map<String, dynamic>>[].obs;
  var hasAlarm = false.obs;

  var selectedCategory = 'All'.obs;
  final List<String> categories = [
    'All',
    'Food',
    'FreshCut',
    'DailyMio',
    'Pharmacy'
  ];

  /// Dashboard Stats
  var stats = <Map<String, dynamic>>[
    {"title": "Customers", "count": "0", "color": const Color(0xFF0F0FBA), "icons": Icons.people_outline},
    {"title": "Orders", "count": "0", "color": const Color(0xFFEDA917), "icons": Icons.card_giftcard_outlined},
    {"title": "Restaurants", "count": "0", "color": const Color(0xFFA032F4), "icons": Icons.business},
    {"title": "Products", "count": "0", "color": const Color(0xFF171717), "icons": Icons.inventory_2},
    {"title": "Unassigned \n Orders", "count": "0", "color": const Color(0xFFFF8800), "icons": Icons.unpublished_outlined},
    {"title": "Accepted by \n Delivery Man", "count": "0", "color": const Color(0xFF1FCD3D), "icons": Icons.gpp_good_outlined},
    {"title": "Packaging", "count": "0", "color": const Color(0xFF26A69A), "icons": Icons.calculate},
    {"title": "Out of \n delivery", "count": "0", "color": const Color(0xFF123DC8), "icons": Icons.local_shipping},
    {"title": "Delivered", "count": "0", "color": const Color(0xFF1BC538), "icons": Icons.system_security_update_good},
    {"title": "Cancelled", "count": "0", "color": const Color(0xFFEA3C3C), "icons": Icons.cancel_presentation},
    {"title": "Refunded", "count": "0", "color": const Color(0xFFDF332A), "icons": Icons.attach_money},
    {"title": "Payment \n Failed", "count": "0", "color": const Color(0xFF731410), "icons": Icons.sms_failed_outlined},
  ].obs;

  /// 🔹 Recently Joined Sellers
  var recentSellers = <Map<String, dynamic>>[].obs;

  /// 🔹 Recently Added Products
  var recentProducts = <Map<String, dynamic>>[].obs;

  /// 🔹 Recently Added Delivery Persons
  var recentDeliveryPersons = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadZonesFromSession();
    _fetchStats();
    fetchRecentSellers();
    fetchRecentProducts();
    fetchRecentDeliveryPersons();
  }
  void toggleAlarm() {
    hasAlarm.value = !hasAlarm.value;
  }
  // ---------------- STATS ----------------
  Future<void> _fetchStats() async {
    try {
      final customerCount = await FirebaseFirestore.instance.collection('Userdetails').count().get();
      final orderCount = await FirebaseFirestore.instance.collection('orders').count().get();
      final restaurantCount = await FirebaseFirestore.instance.collection('Shops').count().get();
      final productCount = await FirebaseFirestore.instance.collection('products').count().get();

      updateStat("Customers", customerCount.count.toString());
      updateStat("Orders", orderCount.count.toString());
      updateStat("Restaurants", restaurantCount.count.toString());
      updateStat("Products", productCount.count.toString());
    } catch (e) {
      print("Error fetching stats: $e");
      Get.snackbar("Error", "Failed to load dashboard data.");
    }
  }

  void updateStat(String title, String newCount) {
    int index = stats.indexWhere((stat) => stat["title"] == title);
    if (index != -1) {
      var updatedStat = Map<String, dynamic>.from(stats[index]);
      updatedStat["count"] = newCount;
      stats[index] = updatedStat;
    }
  }

  // ---------------- ZONES ----------------
  Future<void> _loadZonesFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('adminSession');

    if (sessionJson != null) {
      final sessionData = jsonDecode(sessionJson);
      final List<dynamic> zonesData = sessionData['zonesData'] ?? [];
      zones.assignAll(zonesData.cast<Map<String, dynamic>>());

      final primaryZoneId = sessionData['primaryZoneId'];
      if (primaryZoneId != null && zones.any((z) => z['zoneId'] == primaryZoneId)) {
        selectedZoneId.value = primaryZoneId;
      } else if (zones.isNotEmpty) {
        selectedZoneId.value = zones.first['zoneId'];
      }

      if (selectedZoneId.value != null) {
        await fetchOrdersByZone(selectedZoneId.value!);
      }
    }
  }

  Future<void> onZoneChanged(String? newZoneId) async {
    if (newZoneId == null || newZoneId == selectedZoneId.value) return;
    selectedZoneId.value = newZoneId;
    await fetchOrdersByZone(newZoneId);
  }

  void onCategoryChanged(String? newCategory) {
    if (newCategory != null) {
      selectedCategory.value = newCategory;
      print("Fetching data for zone ${selectedZoneId.value} and category $newCategory...");
    }
  }

  Future<void> fetchOrdersByZone(String zoneId) async {
    print("Fetching orders for $zoneId ...");
  }

  // ---------------- FETCH RECENT DATA ----------------
  Future<void> fetchRecentSellers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      recentSellers.assignAll(snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print("Error fetching sellers: $e");
    }
  }

  Future<void> fetchRecentProducts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      recentProducts.assignAll(snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  Future<void> fetchRecentDeliveryPersons() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('deliveryboy')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      recentDeliveryPersons.assignAll(snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print("Error fetching delivery persons: $e");
    }
  }
}
