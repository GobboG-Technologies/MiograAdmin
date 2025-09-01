// controller/liveOrderCon.dart

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiveOrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- STATE VARIABLES ---
  var liveorders = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;

  // --- NEW: Zone Management State ---
  var zones = <Map<String, dynamic>>[].obs;
  var selectedZoneId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    // Load admin data and fetch initial live orders
    _loadAdminSessionAndFetchData();
    // Debounce search queries to avoid excessive reads
    debounce(searchQuery, (_) => update(), time: const Duration(milliseconds: 300));
  }

  /// --- NEW: Getter for filtered orders based on search query ---
  List<Map<String, dynamic>> get filteredLiveOrders {
    if (searchQuery.value.isEmpty) {
      return liveorders;
    }

    final lowerQuery = searchQuery.value.toLowerCase();
    return liveorders.where((order) {
      final orderId = order["id"]?.toString().toLowerCase() ?? "";
      return orderId.contains(lowerQuery);
    }).toList();
  }

  /// --- NEW: Method to load zones and fetch initial data ---
  Future<void> _loadAdminSessionAndFetchData() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString('adminSession');

      if (sessionJson == null) {
        print("⚠️ No admin session found in SharedPreferences");
        isLoading.value = false;
        return;
      }

      final sessionData = jsonDecode(sessionJson);
      final List<dynamic> zonesData = sessionData['zonesData'] ?? [];

      if (zonesData.isNotEmpty) {
        zones.assignAll(zonesData.cast<Map<String, dynamic>>());

        final primaryZoneId = sessionData['primaryZoneId'];
        if (primaryZoneId != null && zones.any((z) => z['zoneId'] == primaryZoneId)) {
          selectedZoneId.value = primaryZoneId;
        } else {
          selectedZoneId.value = zones.first['zoneId'];
        }

        if (selectedZoneId.value != null) {
          await fetchLiveOrdersByZone(selectedZoneId.value!);
        }
      } else {
        print("⚠️ No zones found in admin session data");
      }
    } catch (e) {
      print("❌ Error loading admin session: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// --- NEW: Public method to handle zone changes from the UI ---
  Future<void> onZoneChanged(String? newZoneId) async {
    if (newZoneId == null || newZoneId == selectedZoneId.value) {
      return;
    }
    selectedZoneId.value = newZoneId;
    liveorders.clear(); // Clear old orders
    searchQuery.value = ''; // Reset search
    await fetchLiveOrdersByZone(newZoneId);
  }

  /// --- MODIFIED: Fetches live orders for a specific zoneId ---
  Future<void> fetchLiveOrdersByZone(String zoneId) async {
    try {
      isLoading.value = true;
      print("🔍 Fetching 'Live' orders for zoneId: $zoneId");

      final snapshot = await _firestore
          .collection('orders')
          .where('zoneId', isEqualTo: zoneId)
          .where('status', whereIn: ['Accepted', 'Out_For_Delivery'])
          .get();

      print("🔥 Live orders fetched for zone $zoneId: ${snapshot.docs.length}");

      liveorders.assignAll(
        snapshot.docs.map((doc) {
          final data = doc.data();
          final items = (data['items'] as List<dynamic>? ?? []).map((item) {
            return {
              'id': item['id'] ?? '',
              'name': item['productName'] ?? 'Unnamed Product',
              'imageUrl': item['imageUrl'] ?? 'https://via.placeholder.com/150',
              'option': (item['foodType']?.toLowerCase() == 'veg') ? 'veg' : 'nonveg',
            };
          }).toList();

          final Timestamp? timestamp = data['timestamp'];

          return {
            'id': doc.id,
            'restaurant': data['shopName'] ?? 'Unknown Shop',
            'items': items,
            'address': [
              data['deliveryAddress']?['house Name'],
              data['deliveryAddress']?['landmark'],
              data['deliveryAddress']?['city'],
            ].where((e) => e != null && e.isNotEmpty).join(', '),
            'paymentMode': (data['paymentId'] == null || (data['paymentId'] as String).isEmpty) ? "COD" : "UPI",
            'amount': (data['totalPrice'] ?? 0).toStringAsFixed(2),
            'time': timestamp != null ? DateFormat('h:mm a').format(timestamp.toDate()) : 'N/A',
            'date': timestamp != null ? DateFormat('MMM d, yyyy').format(timestamp.toDate()) : 'N/A',
            'shopId': data['shopId'] ?? 'N/A',
          };
        }).toList(),
      );

      print("✅ Live orders list updated: ${liveorders.length}");
    } catch (e) {
      print("❌ Error fetching live orders: $e");
      Get.snackbar("Error", "Failed to load live orders.");
    } finally {
      isLoading.value = false;
    }
  }
}