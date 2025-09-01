import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/orderController.dart';

class OrderListPage extends StatelessWidget {
  final OrderController controller = Get.put(OrderController());

  OrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("Loading Orders..."),
                      ],
                    ),
                  );
                }

                // Permission check
                if (!controller.hasPermission.value) {
                  return const Center(
                    child: Text(
                      "You don't have permission to view orders.",
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  );
                }

                if (controller.filteredOrders.isEmpty) {
                  return const Center(
                    child: Text(
                      "No requested orders found for this zone.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 1200
                        ? 3
                        : (constraints.maxWidth > 800 ? 2 : 1);

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: controller.filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = controller.filteredOrders[index];
                        return RequestOrderCard(
                          order: order,
                          index: index,
                          controller: controller, // pass controller
                        );
                      },
                    );
                  },
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Row(
          children: [
            Expanded(child: _buildSearchBar()),
            const SizedBox(width: 20),
            _buildZoneDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        onChanged: (value) => controller.searchQuery.value = value,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          hintText: "Search By Order ID",
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
        ),
      ),
    );
  }

  Widget _buildZoneDropdown() {
    return Obx(() {
      if (controller.zones.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text("No Zones", style: TextStyle(color: Colors.grey)),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedZoneId.value,
            hint: const Text("Select Zone"),
            items: controller.zones.map((zone) {
              return DropdownMenuItem<String>(
                value: zone['zoneId'] as String,
                child: Text(zone['zoneName'] as String,
                    style: const TextStyle(color: Colors.black87)),
              );
            }).toList(),
            onChanged: (newValue) => controller.onZoneChanged(newValue),
          ),
        ),
      );
    });
  }
}

/// RequestOrderCard
class RequestOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final int index;
  final OrderController controller;

  const RequestOrderCard({
    Key? key,
    required this.order,
    required this.index,
    required this.controller,
  }) : super(key: key);

  String _formatTimestamp(dynamic timestamp, String format) {
    if (timestamp == null) return "N/A";
    if (timestamp is Timestamp) return DateFormat(format).format(timestamp.toDate());
    try {
      return DateFormat(format).format(DateTime.parse(timestamp.toString()));
    } catch (e) {
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List items = order["items"] as List? ?? [];
    final bool isCOD =
    (order["paymentId"] == null || (order["paymentId"] as String).isEmpty);
    final String shopName = order["shopName"] ??
        (items.isNotEmpty ? items[0]['shopName'] ?? 'Unknown Shop' : 'Unknown Shop');

    final addressMap = order["deliveryAddress"] ?? {};
    final addressText = [
      addressMap["house Name"],
      addressMap["landmark"],
      addressMap["city"],
      addressMap["fullAddress"],
    ]
        .where((e) => e != null && e.toString().isNotEmpty && e.toString() != "null")
        .join(", ");

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Order ID: ${order["docId"] ?? 'N/A'}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 10),
              Center(
                child: Text(shopName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600])),
              ),
              const SizedBox(height: 10),
              if (items.isNotEmpty)
                ...items.map((item) {
                  final bool isVeg =
                      (item["foodType"] as String?)?.toLowerCase() == "veg";
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            item["imageUrl"] ?? '',
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 60,
                              width: 60,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item["productName"] ?? 'Unnamed Product',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.w600)),
                              Row(
                                children: [
                                  Icon(Icons.circle,
                                      color: isVeg ? Colors.green : Colors.red,
                                      size: 14),
                                  const SizedBox(width: 4),
                                  Text(isVeg ? "Veg" : "Non-Veg",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey[700])),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text("x ${item['count'] ?? 1}",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              const SizedBox(height: 12),
              Text("Address",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[900],
                      fontSize: 17)),
              const SizedBox(height: 8),
              Text(addressText.isEmpty ? 'Address not available' : addressText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                      isCOD ? "assets/images/cod.png" : "assets/images/upi.png",
                      height: 25,
                      width: 39),
                  Row(
                    children: [
                      Icon(Icons.currency_rupee_sharp, color: Colors.purple[900]),
                      Text((order["totalPrice"] ?? 0).toStringAsFixed(2),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[900],
                              fontSize: 20)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatTimestamp(order["timestamp"], 'MMM d, yyyy'),
                        style: TextStyle(
                            color: Colors.purple[900],
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      Text(
                        _formatTimestamp(order["timestamp"], 'h:mm a'),
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // 🚨 Cancel button
                  ElevatedButton(
                    onPressed: () async {
                      await controller.cancelOrder(order["docId"]);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Cancel"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
