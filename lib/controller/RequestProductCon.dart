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
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('zoneId', isEqualTo: zoneId)
          // .where('status', isEqualTo: 'pending')
          .where('status', whereIn: ['pending', 'Pending'])

          .get();

      products.assignAll(snapshot.docs.map((doc) {
        final data = doc.data();
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
    } catch (e) {
      print("❌ Error fetching products for zone: $e");
    }
  }

  /// Approve product
  Future<void> toggleApproval(int index) async {
    final product = products[index];
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update({'status': 'accepted'});
      products.removeAt(index);
    } catch (e) {
      print("❌ Error approving product: $e");
    }
  }

  /// Reject product
  Future<void> rejectProduct(int index) async {
    final product = products[index];
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update({'status': 'Rejected'});
      products.removeAt(index);
    } catch (e) {
      print("❌ Error rejecting product: $e");
    }
  }
}
