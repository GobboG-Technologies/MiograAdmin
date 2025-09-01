import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controller/BusinessViewController.dart';

class BusinessView extends StatelessWidget {
  final String shopId;

  const BusinessView({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    // Instantiate the controller, passing the shopId to it
    final BusinessViewController controller = Get.put(BusinessViewController(shopId: shopId));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Top bar with Title and Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Business & Product Overview",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF583081),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text("Close", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),

              // Main content area
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.error.value != null) {
                    return Center(child: Text("Error: ${controller.error.value}", style: const TextStyle(color: Colors.red)));
                  }
                  if (controller.shopData.value == null) {
                    return const Center(child: Text("Shop data not found."));
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Panel: Shop Details
                      Expanded(
                        flex: 2,
                        child: _buildShopDetailsCard(controller.shopData.value!),
                      ),
                      const SizedBox(width: 24),
                      // Right Panel: Product Grid
                      Expanded(
                        flex: 5,
                        child: _buildProductGrid(controller.productList.value),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to display shop details in a card
  Widget _buildShopDetailsCard(Map<String, dynamic> data) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(data['profileImage'] ?? ''),
                onBackgroundImageError: (e, s) => const Icon(Icons.store, size: 50),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                data['name'] ?? 'N/A',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(height: 30),
            _buildDetailRow(Icons.person, "Owner", data['ownerName'] ?? 'N/A'),
            _buildDetailRow(Icons.phone, "Contact", data['contact'] ?? 'N/A'),
            _buildDetailRow(Icons.email, "Email (Added By)", data['addedBy'] ?? 'N/A'),
            _buildDetailRow(Icons.location_on, "Address", data['address'] ?? 'N/A'),
            _buildDetailRow(Icons.business, "GST", data['GST'] ?? 'N/A'),
            _buildDetailRow(Icons.schedule, "Timings", "${data['openTime']} - ${data['closeTime']}"),
            _buildDetailRow(Icons.map, "Delivery Zone", data['deliveryZone'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  // Helper for formatting detail rows
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.purple[700], size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 15, color: Colors.grey[800])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ UPDATED WIDGET: Displays products with the new data structure
  Widget _buildProductGrid(List<QueryDocumentSnapshot> products) {
    if (products.isEmpty) {
      return const Center(child: Text("No products found for this shop.", style: TextStyle(fontSize: 16)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Products from this Shop", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7, // Adjusted for more content
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final productData = products[index].data() as Map<String, dynamic>;

              // Extract data using the new field names
              final String imageUrl = productData['imageUrl'] ?? '';
              final String productName = productData['productName'] ?? 'No Name';
              final String yourPrice = productData['yourprice'] ?? '0';
              final String productPrice = productData['productPrice'] ?? '0';
              final String mainCategory = productData['mainCategory'] ?? 'N/A';
              final String subCategory = productData['subCategory'] ?? 'N/A';
              final String foodType = productData['foodType'] ?? 'N/A';
              final String deliveryZone = productData['deliveryzone'] ?? 'N/A';

              return Card(
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product Image
                    Expanded(
                      flex: 3,
                      child: Container(
                        color: Colors.grey[200],
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                          const Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 50),
                        )
                            : const Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 50),
                      ),
                    ),
                    // Product Details
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name
                            Text(
                              productName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),

                            // Price
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "₹$yourPrice",
                                  style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "₹$productPrice",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Categories and Food Type
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "$mainCategory > $subCategory",
                                    style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    foodType,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Delivery Zone
                            Row(
                              children: [
                                Icon(Icons.public, size: 12, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  deliveryZone,
                                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}