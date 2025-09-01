// live_list_page.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import your controller
import '../../controller/liveOrderCOn.dart';

class LiveListPage extends StatelessWidget {
  final LiveOrderController controller = Get.put(LiveOrderController());

  LiveListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- NEW: Header with Search and Dropdown ---
            _buildHeader(),
            const SizedBox(height: 30),
            Expanded(
              // --- MODIFIED: Obx listens to controller state changes ---
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("Loading Live Orders..."),
                      ],
                    ),
                  );
                }

                if (controller.filteredLiveOrders.isEmpty) {
                  return const Center(
                    child: Text(
                      "No live orders found for this zone.",
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
                      // Use the filtered list
                      itemCount: controller.filteredLiveOrders.length,
                      itemBuilder: (context, index) {
                        final order = controller.filteredLiveOrders[index];
                        return LiveOrderCard(
                          order: order,
                          index: index,
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

  /// --- NEW: Header Widget ---
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

  /// --- MODIFIED: Search Bar now connected to controller ---
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

  /// --- NEW: Zone Dropdown Widget ---
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
                child: Text(
                  zone['zoneName'] as String,
                  style: const TextStyle(color: Colors.black87),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              controller.onZoneChanged(newValue);
            },
          ),
        ),
      );
    });
  }
}

// No changes are needed for your LiveOrderCard widget.
// It remains the same as you provided it.
class LiveOrderCard extends StatelessWidget {
  final Map order;
  final int index;

  const LiveOrderCard({
    Key? key,
    required this.order,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The code for this widget is unchanged.
    // ... (Your existing LiveOrderCard code here)
    final LiveOrderController controller = Get.find<LiveOrderController>();
    final List items = order["items"] as List? ?? [];

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView( // Added for better small-screen support
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Order ID: ${order["id"]}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  order["restaurant"],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 10),

              if (items.isNotEmpty)
                ...items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            item['imageUrl'] ?? 'https://via.placeholder.com/150',
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              height: 60,
                              width: 60,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["name"],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    item["option"] == "veg" ? Icons.circle : Icons.circle,
                                    color: item["option"] == "veg" ? Colors.green : Colors.red,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item["option"] == "veg" ? "Veg" : "Non-Veg",
                                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

              const SizedBox(height: 12),

              Text("Address", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple[900], fontSize: 17)),
              const SizedBox(height: 8),
              Text(
                order["address"],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    order["paymentMode"] == "COD" ? "assets/images/cod.png" : "assets/images/upi.png",
                    height: 25,
                    width: 39,
                  ),
                  Row(
                    children: [
                      Icon(Icons.currency_rupee_sharp, color: Colors.purple[900]),
                      Text(
                        order["amount"],
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple[900], fontSize: 20),
                      ),
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
                      Text(order["date"], style: TextStyle(color: Colors.purple[900], fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(order["time"], style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_pin_circle_outlined, color: Colors.purple[900]),
                          const SizedBox(width: 5),
                          Text(order["shopId"], style: TextStyle(color: Colors.purple[900], fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ],
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