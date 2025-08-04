import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderController extends GetxController {
  var selectedTab = 0.obs;
  var orders = <Map<String, dynamic>>[].obs; // All orders for zone
  var searchQuery = ''.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Zone data
  List<int> zonePincodes = [];
  List<LatLng> zonePoints = [];

  @override
  void onInit() {
    super.onInit();
    fetchOrdersByZone(); // Fetch orders by zone on init
  }
  List<Map<String, dynamic>> get filteredOrders {
    if (searchQuery.value.isEmpty) return orders;

    // Separate matching and non-matching orders
    final lowerQuery = searchQuery.value.toLowerCase();
    final matching = orders.where((order) {
      final docId = order["docId"]?.toString().toLowerCase() ?? "";
      return docId.contains(lowerQuery);
    }).toList();

    final nonMatching = orders.where((order) {
      final docId = order["docId"]?.toString().toLowerCase() ?? "";
      return !docId.contains(lowerQuery);
    }).toList();

    // Merge: matching first, then rest
    return [...matching, ...nonMatching];
  }


  // Example: Call this after fetching orders from Firestore
  void setOrders(List<Map<String, dynamic>> newOrders) {
    orders.assignAll(newOrders);
  }
  /// Fetch all orders filtered by zoneId only (no status filter)
  Future<void> fetchOrdersByZone() async {
    try {
      // 1. Get zone data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final zoneJson = prefs.getString('zoneData');

      if (zoneJson == null) {
        print("⚠️ No zone data found in SharedPreferences");
        return;
      }

      final zoneData = jsonDecode(zoneJson);
      final zoneId = zoneData['zoneId'];

      if (zoneId == null || zoneId.isEmpty) {
        print("⚠️ Zone ID missing in zoneData");
        return;
      }

      print("🔍 Fetching 'requested' orders for zoneId: $zoneId");

      // 2. Query Firestore: orders where zoneId matches AND status is 'requested'
      final snapshot = await _firestore
          .collection('orders')
          .where('zoneId', isEqualTo: zoneId)
          .where('status', isEqualTo: 'Requested') // <-- Filter by status
          .get();

      print("🔥 Requested orders fetched for zoneId $zoneId: ${snapshot.docs.length}");

      // 3. Map documents to list and update observable
      orders.assignAll(
        snapshot.docs.map((doc) {
          final data = doc.data();
          data['docId'] = doc.id;
          return data;
        }).toList(),
      );

      print("✅ Orders list updated (requested only): ${orders.length}");
    } catch (e) {
      print("❌ Error fetching requested orders by zone: $e");
    }
  }


  /// Extract products from current orders
  List<Map<String, dynamic>> getAllProductsFromOrders() {
    final List<Map<String, dynamic>> allProducts = [];

    for (var order in orders) {
      final orderId = order["id"] ?? order["docId"] ?? "";

      final String shopName = (order["items"] as List).isNotEmpty
          ? order["items"][0]['shopName'] ?? "Unknown Shop"
          : "Unknown Shop";

      if (order["items"] is List) {
        for (var item in order["items"]) {
          if (item is Map<String, dynamic>) {
            allProducts.add({
              "orderId": orderId,
              "shopName": shopName,
              "name": item["productName"] ?? item["name"] ?? "",
              "id": item["id"] ?? "",
              "qty": item["count"]?.toString() ??
                  item["productQty"]?.toString() ??
                  "1",
              "price": item["productPrice"]?.toString() ?? "0",
              "yourPrice": item["yourprice"]?.toString() ?? "",
              "option": (item["foodType"]?.toLowerCase() == "veg")
                  ? "veg"
                  : "nonveg",
              "image": item["imageUrl"] ?? "",
              "category": item["mainCategory"] ?? "",
              "subCategory": item["subCategory"] ?? "",
              "status": order["status"] ?? "",
            });
          }
        }
      }
    }

    return allProducts;
  }

  /// Fetch product image URL from Firebase Storage
  Future<String> getImageUrl(String fileName) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('product_images/krishnamayam/$fileName');

      return await ref.getDownloadURL();
    } catch (e) {
      print('🔥 Error getting image URL: $e');
      return '';
    }
  }
}
