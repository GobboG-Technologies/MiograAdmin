import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/RequestBusinessModel.dart';

class RequestBusinessController extends GetxController {
  var businesses = <RequestBusiness>[].obs;
  List<int> zonePincodes = [];
  List<LatLng> zonePoints = [];

  @override
  void onInit() {
    super.onInit();
    loadZoneDataAndShops();
  }

  /// Load zone data and then fetch shops
  Future<void> loadZoneDataAndShops() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final zoneJson = prefs.getString('zoneData');

      if (zoneJson == null) {
        print("⚠️ No zone data found in SharedPreferences");
        return;
      }

      final zoneData = jsonDecode(zoneJson);
      _parseZoneData(zoneData);

      await fetchShopsByZone();
    } catch (e) {
      Get.snackbar("Error", "Failed to load zone data: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  /// Fetch shops with status 'Pending' and inside zone/pincode
  Future<void> fetchShopsByZone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final zoneJson = prefs.getString('zoneData');

      if (zoneJson == null) {
        print("⚠️ No zone data found in SharedPreferences");
        return;
      }

      final zoneData = jsonDecode(zoneJson);
      final zoneId = zoneData['zoneId']; // get zoneId

      if (zoneId == null || zoneId.isEmpty) {
        print("⚠️ zoneId not found in SharedPreferences");
        return;
      }

      final firestore = FirebaseFirestore.instance;

      // ✅ Fetch only shops with this zoneId and status Pending
      final snapshot = await firestore
          .collection('Shops')
          .where('zoneId', isEqualTo: zoneId)
          .where('status', isEqualTo: 'Pending')
          .get();

      print("🔥 Pending shops fetched for zoneId $zoneId: ${snapshot.docs.length}");

      businesses.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        businesses.add(RequestBusiness(
          name: data['name'] ?? '',
          address: data['address'] ?? '',
          id: doc.id,
          location: data['location']?['placeName'] ?? '',
          imageUrl: data['profileImage'] ?? 'assets/images/img9.png',
          isLive: true,
          isApproved: false,
          isRejected: false,
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


  /// Approve shop
  Future<void> approveShop(int index) async {
    try {
      final shop = businesses[index];
      await FirebaseFirestore.instance
          .collection('Shops')
          .doc(shop.id)
          .update({'status': 'accepted'});

      // Remove from local list so UI updates automatically
      businesses.removeAt(index);

      // Optional: re-fetch all shops
       await fetchShopsByZone();

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


  /// Reject shop
  Future<void> rejectShop(int index) async {
    try {
      final shop = businesses[index];
      await FirebaseFirestore.instance
          .collection('Shops')
          .doc(shop.id)
          .update({'status': 'rejected'});

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

  // --- Helper functions ---

  /// Parse pincodes & zone points
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

  /// Check if shop is inside zone (polygon or pincode)
  bool _isShopInZone(Map<String, dynamic> data) {
    final lat = (data['location']?['latitude'] ?? 0).toDouble();
    final lng = (data['location']?['longitude'] ?? 0).toDouble();

    final isInPolygon = _isPointInPolygon(LatLng(lat, lng), zonePoints);
    final shopPincode = _extractPincode(data['address']);
    final isPincodeMatch =
    zonePincodes.map((e) => e.toString()).contains(shopPincode);

    print(
        "🔍 Checking ${data['name']} | LatLng: $lat,$lng | Polygon: $isInPolygon | Pincode: $shopPincode | Match: $isPincodeMatch");

    // If polygon is empty, rely on pincode match
    if (zonePoints.isEmpty) return isPincodeMatch;

    return isInPolygon || isPincodeMatch;
  }

  /// Extract pincode from address string
  String _extractPincode(String? address) {
    if (address == null) return '';
    final regex = RegExp(r'PIN[:\s]+(\d{3,6})');
    final match = regex.firstMatch(address);
    return match?.group(1) ?? '';
  }

  /// Check if point lies inside polygon
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

  /// Ray casting algorithm for polygon intersection
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

  /// Toggle approval (helper for UI)
  void toggleApproval(int index) {
    approveShop(index);
  }
}
