import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/Banner_Model.dart';

class BannerController extends GetxController {
  // 🔹 Banner Data
  var banners = <BannerModel>[].obs;

  // 🔹 Zone Data
  var zones = <Map<String, dynamic>>[].obs;
  var selectedZoneId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _loadDummyBanners();
    loadZonesFromSession();
  }

  /// -------------------  BANNERS -------------------

  /// Load Dummy Banners from assets (sample data)
  Future<void> _loadDummyBanners() async {
    try {
      final byteData1 = await rootBundle.load('assets/images/img10.png');
      final byteData2 = await rootBundle.load('assets/images/img11.png');
      final byteData3 = await rootBundle.load('assets/images/img12.png');

      banners.addAll([
        BannerModel(
          imageBytes: byteData1.buffer.asUint8List(),
          name: 'Chinese',
          startDate: '01-01-2025, 10:00 AM',
          endDate: '10-01-2025, 10:00 AM',
          category: 'Category',
          isActive: true,
        ),
        BannerModel(
          imageBytes: byteData2.buffer.asUint8List(),
          name: 'Italian',
          startDate: '05-01-2025, 12:00 PM',
          endDate: '15-01-2025, 12:00 PM',
          category: 'Category',
          isActive: true,
        ),
        BannerModel(
          imageBytes: byteData3.buffer.asUint8List(),
          name: 'Indian',
          startDate: '08-01-2025, 09:00 AM',
          endDate: '18-01-2025, 09:00 AM',
          category: 'Category',
          isActive: true,
        ),
      ]);
    } catch (e) {
      print("Error loading dummy banners: $e");
    }
  }

  /// Toggle Banner Active Status
  void toggleBannerStatus(int index) {
    banners[index].isActive = !banners[index].isActive;
    banners.refresh();
  }

  /// Remove Banner
  void removeBanner(int index) {
    banners.removeAt(index);
  }

  /// -------------------  ZONES -------------------

  Future<void> loadZonesFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('adminSession');

    if (sessionJson == null) return;
    final sessionData = jsonDecode(sessionJson);

    final List<dynamic> zonesData = sessionData['zonesData'] ?? [];
    zones.assignAll(zonesData.cast<Map<String, dynamic>>());

    final primaryZoneId = sessionData['primaryZoneId'];
    if (primaryZoneId != null &&
        zones.any((z) => z['zoneId'] == primaryZoneId)) {
      selectedZoneId.value = primaryZoneId;
    } else if (zones.isNotEmpty) {
      selectedZoneId.value = zones.first['zoneId'];
    }
  }

  Future<void> onZoneChanged(String? newZoneId) async {
    if (newZoneId == null || newZoneId == selectedZoneId.value) return;
    selectedZoneId.value = newZoneId;

    // 🔹 You can filter banners by zone here if needed
    // await fetchBannersByZone(newZoneId);
  }
}
