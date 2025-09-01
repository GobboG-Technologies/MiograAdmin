import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var orders = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;
  var hasPermission = true.obs;

  var selectedTab = 0.obs;

  var zones = <Map<String, dynamic>>[].obs;
  var selectedZoneId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _loadAdminSessionAndFetchData();
    debounce(searchQuery, (_) => update(), time: const Duration(milliseconds: 300));
  }

  List<Map<String, dynamic>> get filteredOrders {
    if (searchQuery.value.isEmpty) return orders;
    final lowerQuery = searchQuery.value.toLowerCase();
    return orders.where((order) {
      final docId = order["docId"]?.toString().toLowerCase() ?? "";
      return docId.contains(lowerQuery);
    }).toList();
  }

  Future<void> _loadAdminSessionAndFetchData() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString('adminSession');

      if (sessionJson == null) {
        print("⚠️ No admin session found");
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
          await fetchOrdersByZone(selectedZoneId.value!);
        }
      } else {
        print("⚠️ No zones found in admin session data");
        isLoading.value = false;
      }
    } catch (e) {
      print("❌ Error loading admin session: $e");
      Get.snackbar("Error", "Could not load admin session data.");
      isLoading.value = false;
    }
  }

  Future<void> onZoneChanged(String? newZoneId) async {
    if (newZoneId == null || newZoneId == selectedZoneId.value) return;
    selectedZoneId.value = newZoneId;
    orders.clear();
    searchQuery.value = '';
    await fetchOrdersByZone(newZoneId);
  }

  Future<void> fetchOrdersByZone(String zoneId) async {
    try {
      isLoading.value = true;
      print("🔍 Checking zone permission for zoneId: '$zoneId'");

      final zoneDoc = await _firestore.collection('zone').doc(zoneId).get();

      if (!zoneDoc.exists) {
        print("⚠️ Zone not found for ID: $zoneId");
        isLoading.value = false;
        return;
      }

      final zoneData = zoneDoc.data() ?? {};
      print("📄 Zone data: $zoneData");

      final adminPermissions = zoneData['adminPermissions'];
      if (adminPermissions == null || adminPermissions is! Map) {
        print("⚠️ adminPermissions is missing or not a map.");
        isLoading.value = false;
        return;
      }

      bool orderListEnabled = false;
      (adminPermissions as Map<String, dynamic>).forEach((adminId, perms) {
        if (perms is Map && perms['orderList'] == true) {
          orderListEnabled = true;
        }
      });

      if (!orderListEnabled) {
        print("🚫 No admin has orderList enabled for zone: $zoneId");
        orders.clear();
        hasPermission.value = false;
        isLoading.value = false;
        return;
      } else {
        hasPermission.value = true;
      }

      // ✅ Fetch only orders for zoneId AND deliveryStatus = "pending"
      final snapshot = await _firestore
          .collection('orders')
          .where('zoneIds', arrayContains: zoneId)
          .where('deliveryStatus', isEqualTo: "pending")
          .get();

      final fetchedOrders = snapshot.docs.map((doc) {
        final data = doc.data();
        data['docId'] = doc.id;
        return data;
      }).toList();

      orders.assignAll(fetchedOrders);
      print("✅ ${fetchedOrders.length} pending orders loaded for zone $zoneId.");
    } catch (e) {
      print("❌ Error fetching orders: $e");
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }


  /// 🚨 Cancel order by updating deliveryStatus
  Future<void> cancelOrder(String docId) async {
    try {
      await _firestore.collection("orders").doc(docId).update({
        "deliveryStatus": "CancelbyAdmin",
      });
      Get.snackbar("Success", "Order cancelled and set to pending.");
      // refresh
      if (selectedZoneId.value != null) {
        await fetchOrdersByZone(selectedZoneId.value!);
      }
    } catch (e) {
      print("❌ Error cancelling order: $e");
      Get.snackbar("Error", "Failed to cancel order.");
    }
  }
}
