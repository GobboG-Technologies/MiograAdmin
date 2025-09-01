import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/RequestBusinessModel.dart';

class RequestBusinessController extends GetxController {
  var businesses = <RequestBusiness>[].obs;

  /// 🔹 Zones and selected zone
  var zones = <Map<String, dynamic>>[].obs;
  var selectedZoneId = Rxn<String>();

  List<int> zonePincodes = [];
  List<LatLng> zonePoints = [];

  @override
  void onInit() {
    super.onInit();
    loadZonesFromSession();
  }

  /// 🔹 Load zones from adminSession (stored in SharedPreferences)
  Future<void> loadZonesFromSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString('adminSession');

      if (sessionJson == null) {
        print("⚠ No adminSession found in SharedPreferences");
        return;
      }

      final sessionData = jsonDecode(sessionJson);
      final List<dynamic> zonesData = sessionData['zonesData'] ?? [];
      zones.assignAll(zonesData.cast<Map<String, dynamic>>());

      // Set default selected zone
      final primaryZoneId = sessionData['primaryZoneId'];
      if (primaryZoneId != null &&
          zones.any((z) => z['zoneId'] == primaryZoneId)) {
        selectedZoneId.value = primaryZoneId;
      } else if (zones.isNotEmpty) {
        selectedZoneId.value = zones.first['zoneId'];
      }

      if (selectedZoneId.value != null) {
        await fetchShopsByZone(selectedZoneId.value!);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load zones: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  /// 🔹 Handle zone change from dropdown
  Future<void> onZoneChanged(String? newZoneId) async {
    if (newZoneId == null || newZoneId == selectedZoneId.value) return;
    selectedZoneId.value = newZoneId;
    businesses.clear();
    await fetchShopsByZone(newZoneId);
  }

  /// 🔹 Fetch shops with status 'Pending' for given zoneId
  Future<void> fetchShopsByZone(String zoneId) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final snapshot = await firestore
          .collection('Shops')
          .where('deliveryZoneId', isEqualTo: zoneId) // ✅ updated field
          .where('status', isEqualTo: 'Pending')      // ✅ only Pending
          .get();

      print("🔥 Pending shops fetched for deliveryZoneId $zoneId: ${snapshot.docs.length}");

      businesses.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        businesses.add(RequestBusiness(
          name: data['name'] ?? '',
          address: data['address'] ?? '',
          id: doc.id,
          location: data['location']?['placeName'] ?? '',
          imageUrl: (data['profileImage'] != null && data['profileImage'].toString().isNotEmpty)
              ? data['profileImage']
              : 'assets/images/img9.png',
          isLive: true,
          isApproved: data['status'] == 'accepted', // ✅ map status
          isRejected: data['status'] == 'rejected', // ✅ map status
          bankName: data['BankName'] ?? '',
          gst: data['GST'] ?? '',
          gpayNumber: data['GpayNumber'] ?? '',
          upiNumber: data['UPINumber'] ?? '',
          aadhar: data['aadhar'] ?? '',
          accountNumber: data['accountNumber'] ?? '',
          addedBy: data['addedBy'] ?? '',
        ));
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to fetch pending shops: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  /// 🔹 Approve shop
  Future<void> approveShop(int index) async {
    try {
      final shop = businesses[index];
      await FirebaseFirestore.instance
          .collection('Shops')
          .doc(shop.id)
          .update({'status': 'accepted'});

      await FirebaseFirestore.instance
          .collection('Business')
          .doc(shop.addedBy)
          .collection('Shops')
          .doc(shop.id)
          .update({'status': 'accepted'});

      businesses.removeAt(index);

      Get.snackbar(
        "Success", "${shop.name} approved",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error", "Failed to approve: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// 🔹 Reject shop
  Future<void> rejectShop(int index) async {
    try {
      final shop = businesses[index];
      await FirebaseFirestore.instance
          .collection('Shops')
          .doc(shop.id)
          .update({'status': 'blocked'});

      businesses.removeAt(index);

      Get.snackbar("Rejected", "${shop.name} rejected",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to reject: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  // --- Helper functions (still available if you later need polygon/pincode filtering) ---

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

  void toggleApproval(int index) {
    approveShop(index);
  }
}
