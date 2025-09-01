import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../Models/DeliveryBoyModel.dart';

class blockDeliveryController extends GetxController {
  // var deliveryBoys = <DeliveryBoy>[].obs;

  // 🔹 Zones
  var zones = <Map<String, dynamic>>[].obs;
  var selectedZoneId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _loadZonesFromSession();
  }

  /// 🔹 Load zones from saved session
  Future<void> _loadZonesFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('adminSession');
    if (sessionJson == null) return;

    final sessionData = jsonDecode(sessionJson);
    final List<dynamic> zonesData = sessionData['zonesData'] ?? [];

    zones.assignAll(zonesData.cast<Map<String, dynamic>>());

    final primaryZoneId = sessionData['primaryZoneId'];

  }

  /// 🔹 Zone change handler


  /// 🔹 Fetch delivery boys by zone

}
