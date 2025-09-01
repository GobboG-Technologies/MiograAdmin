import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/deliveryPerson.dart';

class DeliveryPersonController extends GetxController {
  var deliveryPersons = <DeliveryPerson>[].obs;
  var isLoading = false.obs;

  // 🔹 Zones
  var zones = <Map<String, dynamic>>[].obs;
  var selectedZoneId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadZonesFromSession();
  }

  /// Load zones from admin session stored in SharedPreferences
  Future<void> loadZonesFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('adminSession');
    if (sessionJson == null) return;

    final sessionData = jsonDecode(sessionJson);
    final List<dynamic> zonesData = sessionData['zonesData'] ?? [];
    zones.assignAll(zonesData.cast<Map<String, dynamic>>());

    // Set default zone
    final primaryZoneId = sessionData['primaryZoneId'];
    if (primaryZoneId != null &&
        zones.any((z) => z['zoneId'] == primaryZoneId)) {
      selectedZoneId.value = primaryZoneId;
    } else if (zones.isNotEmpty) {
      selectedZoneId.value = zones.first['zoneId'];
    }

    if (selectedZoneId.value != null) {
      await fetchDeliveryPersonsByZone(selectedZoneId.value!);
    }
  }

  /// Fetch delivery persons by selected zone
  Future<void> fetchDeliveryPersonsByZone(String zoneId) async {
    isLoading.value = true;
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('deliveryboy')
          .where('zoneId', isEqualTo: zoneId)
          .get();

      deliveryPersons.value = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return DeliveryPerson(
          id: doc.id,
          name: data['name'] ?? '',
          phone: data['phone'] ?? '',
          address: data['address'] ?? '',
          email: data['email'] ?? '',
          imageUrl: data['profile_image'] ?? '',
          isAvailable: data['status'] == 'online',
        );
      }).toList();
    } catch (e) {
      print('Error fetching delivery persons: $e');
    }
    isLoading.value = false;
  }

  /// When admin selects a new zone
  Future<void> onZoneChanged(String? newZoneId) async {
    if (newZoneId == null || newZoneId == selectedZoneId.value) return;
    selectedZoneId.value = newZoneId;

    deliveryPersons.clear(); // clear old list
    await fetchDeliveryPersonsByZone(newZoneId); // fetch new list
  }

  void toggleLiveStatus(int index) {
    deliveryPersons[index].isAvailable = !deliveryPersons[index].isAvailable;
    update();
  }


}
