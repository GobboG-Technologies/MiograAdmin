import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:miogra_admin/controller/Business&sellerCon.dart';
import 'businessViewPage.dart'; // ✅ FIXED: Correct relative import

import '../../Models/product.dart';
import '../../controller/addShopController.dart';
import '../../controller/productController.dart';
import 'AddBusness.dart';
import 'business_dropdown.dart';

class BusinessGrid extends StatelessWidget {
  final BusinessSellerController controller = Get.put(BusinessSellerController());
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Bar
              Center(child: _buildSearchBar()),
              const SizedBox(height: 50),

              Row(
                children: [
                  // Zone Dropdown
                  Obx(() {
                    if (controller.zones.isEmpty) {
                      return const Text("No Zones");
                    }
                    return DropdownButton<String>(
                      value: controller.selectedZoneId.value,
                      hint: const Text("Select Zone"),
                      items: controller.zones.map((zone) {
                        return DropdownMenuItem<String>(
                          value: zone['zoneId'] as String,
                          child: Text(zone['zoneName'] as String),
                        );
                      }).toList(),
                      onChanged: (newValue) => controller.onZoneChanged(newValue),
                    );
                  }),

                  const SizedBox(width: 20),

                  // Filter Widget
                  FilterWidget(),

                  const Spacer(),

                  // Refresh Button
                  IconButton(
                    tooltip: "Refresh",
                    onPressed: () {
                      controller.loadZoneDataAndShops();
                    },
                    icon: const Icon(Icons.refresh, color: Colors.purple, size: 28),
                  ),

                  const SizedBox(width: 10),

                  // Add Business Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => AddNewBusiness()); // no id → add new
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "Add Business",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Business Grid
              Obx(() => Container(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: controller.businesses.length,
                  itemBuilder: (context, index) {
                    final product = controller.businesses[index];

                    // ✅ WRAP CARD IN GESTUREDETECTOR FOR NAVIGATION
                    return GestureDetector(
                      onTap: () {
                        // Navigate to the detail view with the shop ID
                        Get.to(() => BusinessView(shopId: product.id));
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Image
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              child: buildBusinessImage(product.imageUrl),
                            ),

                            // Content
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ID + Location
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "ID: ${product.id}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.purple[900],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              color: Colors.purple[900],
                                              size: 14),
                                          const SizedBox(width: 2),
                                          Text(
                                            product.location,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  // Business Name
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  // Status (Live/Offline)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        color: product.isLive.value
                                            ? Colors.green
                                            : Colors.red,
                                        size: 10,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        product.isLive.value
                                            ? "Live"
                                            : "Offline",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: product.isLive.value
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  // Address
                                  Text(
                                    product.address,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 6),

                                  // Date
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.purple[900],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Bottom Edit Button
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.purple[900],
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                              ),
                              child: TextButton.icon(
                                onPressed: () {
                                  final id = product.id;
                                  Get.to(() => AddNewBusiness(businessId: id));
                                },
                                icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                                label: const Text(
                                  "Edit",
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  // Search Bar
  Widget _buildSearchBar() {
    return Container(
      width: 600,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          hintText: "Search By Product ID",
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
        ),
      ),
    );
  }
}

// Business Image
Widget buildBusinessImage(String imageUrl) {
  if (imageUrl.startsWith('assets/')) {
    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      height: 150,
      width: double.infinity,
    );
  }

  return Image.network(
    imageUrl,
    fit: BoxFit.cover,
    height: 150,
    width: double.infinity,
    errorBuilder: (context, error, stackTrace) {
      return Image.asset(
        'assets/images/img9.png',
        fit: BoxFit.cover,
        height: 150,
        width: double.infinity,
      );
    },
  );
}