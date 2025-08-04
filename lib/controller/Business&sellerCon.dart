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

  List<int> zonePincodes = [];
  List<LatLng> zonePoints = [];

  @override
  void onInit() {
    super.onInit();
    loadZoneDataAndShops();
  }

  /// Load zone data (coordinates + pincodes) from SharedPreferences
  Future<void> loadZoneDataAndShops() async {
    final prefs = await SharedPreferences.getInstance();
    final zoneJson = prefs.getString('zoneData');

    if (zoneJson != null) {
      final zoneData = jsonDecode(zoneJson);

      // Convert pincodes
      final rawPincodes = zoneData['pincodes'] ?? [];
      zonePincodes = rawPincodes.map<int>((e) {
        if (e is int) return e;
        if (e is String) return int.tryParse(e) ?? 0;
        return 0;
      }).toList();

      // Convert zonePoints (deliveryZoneCoordinates) to LatLng list
      zonePoints = (zoneData['zonePoints'] as List)
          .map((p) => LatLng(
        (p['latitude'] ?? 0).toDouble(),
        (p['longitude'] ?? 0).toDouble(),
      ))
          .toList();

      await fetchShopsByZone();
    }
  }

  /// Fetch shops filtered by zone/pincode and load their images
  /// Fetch shops directly by zoneId (faster)
  Future<void> fetchShopsByZone() async {
    final prefs = await SharedPreferences.getInstance();
    final zoneJson = prefs.getString('zoneData');

    if (zoneJson == null) {
      print("⚠️ No zone data found in SharedPreferences");
      return;
    }

    final zoneData = jsonDecode(zoneJson);
    final zoneId = zoneData['zoneId']; // Get zoneId

    if (zoneId == null || zoneId.isEmpty) {
      print("⚠️ Zone ID missing in zoneData");
      return;
    }

    final firestore = FirebaseFirestore.instance;

    // Query shops where zoneId matches AND status is accepted
    final snapshot = await firestore
        .collection('Shops')
        .where('zoneId', isEqualTo: zoneId)
        .where('status', isEqualTo: 'accepted')
        .get();

    print("🔥 Shops fetched for zoneId $zoneId: ${snapshot.docs.length}");

    // Clear previous businesses
    businesses.clear();

    // Convert each shop into Business model
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
              : 'assets/images/img9.png', // fallback
          isLive: true,
          isApproved: false,
          isRejected: false,
        ),
      );
    }

    print("✅ Businesses list updated (zone filter): ${businesses.length}");
  }



  /// Fetch all image URLs for all email folders under Business/
  Future<Map<String, List<String>>> fetchAllBusinessImages() async {
    final Map<String, List<String>> allImages = {};

    try {
      // Root folder
      final businessRef = FirebaseStorage.instance.ref().child('Business');
      final emailFolders = await businessRef.listAll();

      print("✅ Email folders found in Storage: ${emailFolders.prefixes.length}");
      print("Folders in Firebase Storage (Business/):");
      for (var folder in emailFolders.prefixes) {
        print(" - ${folder.name}");
      }

      // Loop each email folder
      for (var emailFolder in emailFolders.prefixes) {
        final shopsRef = emailFolder.child('Shops');
        final shopFiles = await shopsRef.listAll();

        final urlsForThisEmail = <String>[];
        for (var file in shopFiles.items) {
          final name = file.name.toLowerCase();

          if (name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.png')) {
            final url = await file.getDownloadURL();

            // 🔥 Debug print for each fetched URL
            print("Fetched URL for ${emailFolder.name}: $url");

            urlsForThisEmail.add(url);
          }
        }

        // Map: email (folder name) → URLs
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
