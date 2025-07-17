import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../Models/CustomerModel.dart';
import '../Models/customerHistoryModel.dart';

class CustomerControllerpage extends GetxController {
  var customer = <Customer>[].obs;
  var customerOrder = <customerOrderHistory>[].obs;
  var filteredCustomers = <Customer>[].obs;
  var searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
    loadDummyOrderData();
    ever(searchText, (_) => applySearch());
  }

  void fetchCustomers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Userdetails').get();
      final customersData = snapshot.docs.map((doc) {
        return Customer.fromFirestore(doc.data(), doc.id);
      }).toList();

      customer.assignAll(customersData);
      filteredCustomers.assignAll(customersData); // initially show all
    } catch (e) {
      print("Error fetching customers: $e");
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
          order.customerId == cust.id); // Assuming Customer.id matches order.customerId

      return matchesName || orderMatch;
    }).toList();

    filteredCustomers.assignAll(filtered);
  }
}
