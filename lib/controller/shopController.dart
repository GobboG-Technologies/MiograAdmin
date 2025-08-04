import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopController extends GetxController {
  var selectedShopId = ''.obs;
  var shops = <Map<String, dynamic>>[].obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchShopsByZone();
  }

  Future<void> fetchShopsByZone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final zoneJson = prefs.getString('zoneData');

      if (zoneJson == null) return;

      final zoneData = jsonDecode(zoneJson);
      final zoneId = zoneData['zoneId'];
      if (zoneId == null || zoneId.isEmpty) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('Shops')
          .where('zoneId', isEqualTo: zoneId)
          .where('status', isEqualTo: 'accepted')
          .get();

      shops.assignAll(snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          "id": doc.id,
          "name": data['name'] ?? 'Unnamed Shop',
          "address": data['address'] ?? '',
          "image": data['profileImage'] ?? 'assets/images/idili.png',
          "status": (data['isActive'] ?? false)
              ? const Color(0xFF4CAF50)
              : const Color(0xFFFF9800),
        };
      }).toList());
    } catch (e) {
      print("❌ Error fetching shops: $e");
    }
  }

  List<Map<String, dynamic>> get filteredShops {
    if (searchQuery.value.isEmpty) return shops;

    final query = searchQuery.value.toLowerCase();
    final sortedShops = List<Map<String, dynamic>>.from(shops);

    sortedShops.sort((a, b) {
      final aName = a["name"]?.toString().toLowerCase() ?? '';
      final bName = b["name"]?.toString().toLowerCase() ?? '';
      final aMatch = aName.contains(query);
      final bMatch = bName.contains(query);

      if (aMatch && !bMatch) return -1;
      if (!aMatch && bMatch) return 1;
      return 0;
    });

    return sortedShops;
  }


}
