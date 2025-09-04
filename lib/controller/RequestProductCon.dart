import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/RequestProductModel.dart';

class RequestProductController extends GetxController {
  var products = <RequestProduct>[].obs;

  // Zones
  var zones = <Map<String, dynamic>>[].obs;
  var selectedZoneId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadZonesAndProducts();
  }

  /// Load zones from SharedPreferences and fetch products for selected zone
  Future<void> loadZonesAndProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString('adminSession');
      if (sessionJson == null) return;

      final sessionData = jsonDecode(sessionJson);
      final List<dynamic> zonesData = sessionData['zonesData'] ?? [];
      zones.assignAll(zonesData.cast<Map<String, dynamic>>());

      // Set default selected zone
      final primaryZoneId = sessionData['primaryZoneId'];
      if (primaryZoneId != null && zones.any((z) => z['zoneId'] == primaryZoneId)) {
        selectedZoneId.value = primaryZoneId;
      } else if (zones.isNotEmpty) {
        selectedZoneId.value = zones.first['zoneId'];
      }

      // Fetch products for selected zone
      if (selectedZoneId.value != null) {
        await fetchProductsByZone(selectedZoneId.value!);
      }
    } catch (e) {
      print("❌ Error loading zones: $e");
    }
  }

  /// Called when admin selects a new zone
  Future<void> onZoneChanged(String? newZoneId) async {
    if (newZoneId == null || newZoneId == selectedZoneId.value) return;
    selectedZoneId.value = newZoneId;
    products.clear();
    await fetchProductsByZone(newZoneId);
  }

  /// Fetch products for a specific zone
  Future<void> fetchProductsByZone(String zoneId) async {
    try {
      print("🔍 Fetching products for zone: $zoneId");

      // First, get all products without filters to see what exists
      final allProductsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

      print("📦 Total products in collection: ${allProductsSnapshot.docs.length}");
      print("📋 All product document IDs:");

      // Store all global product IDs for comparison
      List<String> globalProductIds = [];
      for (final doc in allProductsSnapshot.docs) {
        final data = doc.data();
        globalProductIds.add(doc.id);
        print("   - Doc ID: ${doc.id}");
        print("     productName: ${data['productName']}");
        print("     zoneId: ${data['zoneId']}");
        print("     status: ${data['status']}");
        print("     ---");
      }

      // Now check products in nested business/products collections
      print("\n🔍 Checking for globalProductId matches in nested collections...");

      try {
        final businessSnapshot = await FirebaseFirestore.instance
            .collection('business')
            .get();

        for (final businessDoc in businessSnapshot.docs) {
          final businessEmail = businessDoc.id;

          try {
            final nestedProductsSnapshot = await FirebaseFirestore.instance
                .collection('business')
                .doc(businessEmail)
                .collection('products')
                .get();

            for (final nestedProductDoc in nestedProductsSnapshot.docs) {
              final nestedData = nestedProductDoc.data();
              final globalProductId = nestedData['globalProductId'];

              if (globalProductId != null && globalProductIds.contains(globalProductId)) {
                print("🎯 MATCH FOUND!");
                print("   Business: $businessEmail");
                print("   Nested Product Doc ID: ${nestedProductDoc.id}");
                print("   Global Product ID: $globalProductId");
                print("   Product Name: ${nestedData['productName']}");
                print("   Status: ${nestedData['status']}");
                print("   ZoneId: ${nestedData['zoneId']}");
                print("   ✅ This globalProductId exists in the main products collection!");
                print("   ---");
              }
            }
          } catch (e) {
            print("❌ Error checking nested products for $businessEmail: $e");
          }
        }
      } catch (e) {
        print("❌ Error checking business collection: $e");
      }

      // Now get filtered products from main collection
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('zoneId', isEqualTo: zoneId)
          .where('status', whereIn: ['pending', 'Pending'])
          .get();

      print("\n🎯 Filtered products (zoneId=$zoneId, status=pending/Pending): ${snapshot.docs.length}");
      print("🎯 Filtered product document IDs:");
      for (final doc in snapshot.docs) {
        final data = doc.data();
        print("   - Doc ID: ${doc.id}");
        print("     productName: ${data['productName']}");
        print("     ---");
      }

      products.assignAll(snapshot.docs.map((doc) {
        final data = doc.data();
        print("✅ Adding product: ${data['productName']} (ID: ${doc.id})");

        return RequestProduct(
          id: doc.id,
          name: data['productName'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          quantity: int.tryParse(data['productQty'] ?? '0') ?? 0,
          sellerPrice: double.tryParse(data['yourprice'] ?? '0') ?? 0,
          sellingPrice: double.tryParse(data['productPrice'] ?? '0') ?? 0,
          option: (data['foodType'] ?? '').toString().toLowerCase() == 'veg',
          isApproved: false.obs,
          isRejected: false.obs,
        );
      }).toList());

      print("🎉 Total products loaded: ${products.length}");
      print("🔍 Current selectedZoneId: ${selectedZoneId.value}");

    } catch (e) {
      print("❌ Error fetching products for zone: $e");
    }
  }

  /// Approve product
  Future<void> toggleApproval(int index) async {
    final product = products[index];
    print("⏳ Approving product: ${product.name} (ID: ${product.id})");
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update({'status': 'accepted'});
      products.removeAt(index);
      print("✅ Product approved successfully");
    } catch (e) {
      print("❌ Error approving product: $e");
    }
  }

  /// Reject product
  Future<void> rejectProduct(int index) async {
    final product = products[index];
    print("⏳ Rejecting product: ${product.name} (ID: ${product.id})");
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update({'status': 'Rejected'});
      products.removeAt(index);
      print("✅ Product rejected successfully");
    } catch (e) {
      print("❌ Error rejecting product: $e");
    }
  }
}