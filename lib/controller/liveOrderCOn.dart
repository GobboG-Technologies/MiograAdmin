import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiveOrderController extends GetxController {
  var selectedTab = 0.obs; // 0 = Request, 1 = Live Orders

  // Observable list for live orders
  var liveorders = <Map<String, dynamic>>[].obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchLiveOrdersByZone(); // Fetch live orders on init
  }

  /// Fetch orders with status "Live" for current zone
  Future<void> fetchLiveOrdersByZone() async {
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

      print("🔍 Fetching 'Live' orders for zoneId: $zoneId");

      // 2. Query Firestore: Filter by zoneId and status = Live
      final snapshot = await _firestore
          .collection('orders')
          .where('zoneId', isEqualTo: zoneId)
          .where('status', isEqualTo: 'Live')
          .get();

      print("🔥 Live orders fetched: ${snapshot.docs.length}");

      // 3. Update observable list with mapped data
      liveorders.assignAll(
        snapshot.docs.map((doc) {
          final data = doc.data();

          // Map items to correct UI keys
          final items = (data['items'] as List<dynamic>? ?? []).map((item) {
            return {
              'id': item['id'] ?? '',
              'name': item['productName'] ?? '',  // Map productName to name
              'imageUrl': item['imageUrl'] ?? '', // Directly use imageUrl
              'option': (item['foodType']?.toLowerCase() == 'veg') ? 'veg' : 'nonveg',
            };
          }).toList();

          return {
            'id': data['id'] ?? doc.id,
            'restaurant': data['shopName'] ?? '',
            'items': items,
            'address': data['deliveryAddress']?['fullAddress'] ?? '',
            'paymentMode': data['paymentMode'] ?? 'COD',
            'amount': data['totalPrice']?.toString() ?? '0',
            'time': '', // Add if available
            'date': '', // Add if available
            'shopId': data['shopId'] ?? '',
          };
        }).toList(),
      );

      print("✅ Live orders list updated: ${liveorders.length}");
    } catch (e) {
      print("❌ Error fetching live orders: $e");
    }
  }
}
