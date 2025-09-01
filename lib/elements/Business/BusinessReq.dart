import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Models/product.dart';
import '../../controller/RequestBusinessController.dart';
import 'AddBusness.dart';

class RequestBusinessGrid extends StatelessWidget {
  final RequestBusinessController controller =
  Get.put(RequestBusinessController());

  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Search Bar
              Align(
                alignment: Alignment.centerLeft,
                child: Obx(() {
                  if (controller.zones.isEmpty) {
                    return const Text("No Zones Found");
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
                    onChanged: controller.onZoneChanged,
                  );
                }),
              ),
              Center(child: _buildSearchBar()),
              const SizedBox(height: 50),

              // Add Business
              GestureDetector(
                onTap: () => Get.to(() => AddNewBusiness()),
                child: const Text(
                  "+ Add Business",
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 30),

              // Grid
              Obx(() => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemCount: controller.businesses.length,
                itemBuilder: (context, index) {
                  final product = controller.businesses[index];

                  return Obx(() => Opacity(
                    opacity: product.isRejected.value ? 0.5 : 1.0,
                    child: IgnorePointer(
                      ignoring: product.isRejected.value,
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
                              child: buildBusinessImage(
                                  product.imageUrl), // same design
                            ),

                            // Content
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  // ID + Location
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
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

                            const Spacer(),

                            // Bottom Approve & Reject Buttons
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  // Reject
                                  TextButton(
                                    onPressed: () =>
                                        controller.rejectShop(index),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: const BorderSide(
                                          color: Colors.red),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(5)),
                                    ),
                                    child: const Text(
                                      "Reject",
                                      style:
                                      TextStyle(color: Colors.red),
                                    ),
                                  ),

                                  // Approve
                                  Obx(() => TextButton(
                                    onPressed:
                                    product.isRejected.value
                                        ? null
                                        : () => controller
                                        .approveShop(index),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: const BorderSide(
                                          color: Colors.green),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              5)),
                                    ),
                                    child: const Text(
                                      "Approve",
                                      style: TextStyle(
                                          color: Colors.green),
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ));
                },
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

// Reuse image builder (same style)
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
