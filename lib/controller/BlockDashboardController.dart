import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlockDashboardController extends GetxController {
  var selectedTab = "Seller".obs;

  // 🔹 Dynamic zones
  var zones = <Map<String, dynamic>>[].obs;
  var selectedZoneId = Rxn<String>();

  // 🔹 Business-specific
  var selectedBusinessType = "Retail".obs;
  var selectedCategory = "Category A".obs;

  @override
  void onInit() {
    super.onInit();
    loadZonesFromSession();
  }

  Future<void> loadZonesFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('adminSession');

    if (sessionJson != null) {
      final sessionData = jsonDecode(sessionJson);
      final List<dynamic> zonesData = sessionData['zonesData'] ?? [];

      zones.assignAll(zonesData.cast<Map<String, dynamic>>());

      // 🔹 Default zone = primaryZoneId OR first zone
      final primaryZoneId = sessionData['primaryZoneId'];
      if (primaryZoneId != null &&
          zones.any((z) => z['zoneId'] == primaryZoneId)) {
        selectedZoneId.value = primaryZoneId;
      } else if (zones.isNotEmpty) {
        selectedZoneId.value = zones.first['zoneId'];
      }
    }
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  Future<void> onZoneChanged(String? newZoneId) async {
    if (newZoneId == null || newZoneId == selectedZoneId.value) return;
    selectedZoneId.value = newZoneId;

    // 🔹 Clear & refetch data for new zone
    // Example: await fetchOrdersByZone(newZoneId);
  }
}
