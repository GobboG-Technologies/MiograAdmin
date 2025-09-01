import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/SellerModel.dart';

class SellerController extends GetxController {
  var sellers = <Sellers>[].obs;

  // 🔹 Zones
  var zones = <Map<String, dynamic>>[].obs;
  var selectedZoneId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadZonesFromSession();
    fetchSellersFromFirestore();
  }

  Future<void> loadZonesFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('adminSession');
    if (sessionJson == null) return;

    final sessionData = jsonDecode(sessionJson);
    final List<dynamic> zonesData = sessionData['zonesData'] ?? [];
    zones.assignAll(zonesData.cast<Map<String, dynamic>>());

    // 🔹 Set default zone
    final primaryZoneId = sessionData['primaryZoneId'];
    if (primaryZoneId != null &&
        zones.any((z) => z['zoneId'] == primaryZoneId)) {
      selectedZoneId.value = primaryZoneId;
    } else if (zones.isNotEmpty) {
      selectedZoneId.value = zones.first['zoneId'];
    }

    // 🔹 Once zone is set, fetch sellers
    if (selectedZoneId.value != null) {
      await fetchSellersFromFirestore();
    }
  }

  void onZoneChanged(String? newZoneId) async {
    if (newZoneId == null || newZoneId == selectedZoneId.value) return;
    selectedZoneId.value = newZoneId;

    // 🔹 Refresh sellers by zone
    await fetchSellersFromFirestore();
  }

  Future<void> fetchSellersFromFirestore() async {
    try {
      if (selectedZoneId.value == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('zoneId', isEqualTo: selectedZoneId.value) // 🔹 filter by zone
          .get();

      final sellerList = snapshot.docs
          .map((doc) => Sellers.fromMap(doc.data(), doc.id))
          .toList();
      sellers.assignAll(sellerList);
    } catch (e) {
      print("Error fetching sellers: $e");
    }
  }

  void toggleLiveStatus(int index) {
    sellers[index].isLive.value = !sellers[index].isLive.value;
    sellers.refresh();
  }


}
