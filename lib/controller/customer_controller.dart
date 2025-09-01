import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/CustomerModel.dart';
import '../Models/customerHistoryModel.dart';

class CustomerControllerpage extends GetxController {
  var customer = <Customer>[].obs;
  var customerOrder = <customerOrderHistory>[].obs;
  var filteredCustomers = <Customer>[].obs;
  var searchText = ''.obs;

  // 🔹 Zones
  var zones = <Map<String, dynamic>>[].obs;
  var selectedZoneId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _loadZonesFromSession();
    fetchCustomers();
    loadDummyOrderData();
    ever(searchText, (_) => applySearch());
  }

  Future<void> _loadZonesFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('adminSession');
    if (sessionJson == null) return;

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
  }

  Future<void> onZoneChanged(String? newZoneId) async {
    if (newZoneId == null || newZoneId == selectedZoneId.value) return;
    selectedZoneId.value = newZoneId;

    // 🔹 Re-fetch customers by zone if needed
    await fetchCustomersByZone(newZoneId);
  }

  void fetchCustomers() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('Userdetails').get();
      final customersData = snapshot.docs.map((doc) {
        return Customer.fromFirestore(doc.data(), doc.id);
      }).toList();

      customer.assignAll(customersData);
      filteredCustomers.assignAll(customersData); // initially show all
    } catch (e) {
      print("Error fetching customers: $e");
    }
  }

  Future<void> fetchCustomersByZone(String zoneId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Userdetails')
          .where('zoneId', isEqualTo: zoneId)
          .get();

      final customersData = snapshot.docs.map((doc) {
        return Customer.fromFirestore(doc.data(), doc.id);
      }).toList();

      customer.assignAll(customersData);
      filteredCustomers.assignAll(customersData);
    } catch (e) {
      print("Error fetching customers by zone: $e");
    }
  }

  void loadDummyOrderData() {
    customerOrder.addAll([
      customerOrderHistory(
        orderId: "ORID9876543210987654",
        price: 1160,
        time: "09:35 AM",
        date: "29/Jun/2024",
        status: "Delivered",
        paymentMethod: "UPI",
        customerId: "CID98765432101",
      ),
    ]);
  }

  void applySearch() {
    final query = searchText.value.toLowerCase();

    if (query.isEmpty) {
      filteredCustomers.assignAll(customer);
      return;
    }

    final filtered = customer.where((cust) {
      final matchesName = cust.name.toLowerCase().contains(query);
      final orderMatch = customerOrder.any((order) =>
      order.orderId.toLowerCase().contains(query) &&
          order.customerId == cust.id);

      return matchesName || orderMatch;
    }).toList();

    filteredCustomers.assignAll(filtered);
  }
}
