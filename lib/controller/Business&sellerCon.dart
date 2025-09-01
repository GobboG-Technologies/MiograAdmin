import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/BusinessList.dart';
import '../Models/sellerList.dart';

class BusinessSellerController extends GetxController {
  var businesses = <Business>[].obs;
  var sellers = <Seller>[].obs;
  var selectedTab = 0.obs;
  var zones = <Map<String, dynamic>>[].obs;   // All zones for this admin
  var selectedZoneId = RxnString();           // Currently selected zone

  List<int> zonePincodes = [];
  List<LatLng> zonePoints = [];

  @override
  void onInit() {
    super.onInit();
    loadZoneDataAndShops();
  }

  Future<void> loadZoneDataAndShops() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('adminSession');

    if (sessionJson != null) {
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

      if (selectedZoneId.value != null) {
        await fetchShopsByZone(selectedZoneId.value!);
      }
    }
  }

  Future<void> fetchShopsByZone(String zoneId) async {
    final firestore = FirebaseFirestore.instance;

    final snapshot = await firestore
        .collection('Shops')
        .where('deliveryZoneId', isEqualTo: zoneId)
        .where('status', isEqualTo: 'accepted')
        .get();

    businesses.clear();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final profileImageUrl = data['profileImage'] ?? '';

      businesses.add(
        Business(
          name: data['name'] ?? '',
          address: data['address'] ?? '',
          id: doc.id,
          location: data['location']?['placeName'] ?? '',
          imageUrl: profileImageUrl.isNotEmpty
              ? profileImageUrl
              : 'assets/images/img9.png',
          isLive: true,
          isApproved: false,
          isRejected: false,
        ),
      );
    }
  }

  Future<void> onZoneChanged(String? newZoneId) async {
    if (newZoneId == null || newZoneId == selectedZoneId.value) return;
    selectedZoneId.value = newZoneId;
    businesses.clear();
    await fetchShopsByZone(newZoneId);
  }

  /// Fetch all image URLs for all email folders under Business/
  Future<Map<String, List<String>>> fetchAllBusinessImages() async {
    final Map<String, List<String>> allImages = {};

    try {
      final businessRef = FirebaseStorage.instance.ref().child('Business');
      final emailFolders = await businessRef.listAll();

      for (var emailFolder in emailFolders.prefixes) {
        final shopsRef = emailFolder.child('Shops');
        final shopFiles = await shopsRef.listAll();

        final urlsForThisEmail = <String>[];
        for (var file in shopFiles.items) {
          final name = file.name.toLowerCase();
          if (name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.png')) {
            final url = await file.getDownloadURL();
            urlsForThisEmail.add(url);
          }
        }
        allImages[emailFolder.name] = urlsForThisEmail;
      }

      return allImages;
    } catch (e) {
      print("Error fetching images: $e");
      return {};
    }
  }

  bool _rayCastIntersect(LatLng point, LatLng vertA, LatLng vertB) {
    final px = point.latitude;
    final py = point.longitude;
    final ax = vertA.latitude;
    final ay = vertA.longitude;
    final bx = vertB.latitude;
    final by = vertB.longitude;

    if ((ay > py) != (by > py) &&
        px < (bx - ax) * (py - ay) / (by - ay + 0.0) + ax) {
      return true;
    }
    return false;
  }

  void toggleApproval(int index) {
    if (!businesses[index].isRejected.value) {
      businesses[index].isApproved.value = !businesses[index].isApproved.value;
    }
  }

  void rejectProduct(int index) {
    businesses[index].isRejected.value = true;
    businesses[index].isApproved.value = false;
  }
}