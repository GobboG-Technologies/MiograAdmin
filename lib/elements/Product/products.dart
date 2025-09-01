import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/UpdateProductController.dart';
import '../../controller/productController.dart';
import '../../controller/shopController.dart';
import 'AddProduct.dart';
import 'EditProductPage.dart';
import 'ProductDetailsPage.dart';

class ProductGrid extends StatelessWidget {
  final ProductController controller = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildZoneDropdown(),
            const SizedBox(height: 20),
            _buildActionRow(),
            const SizedBox(height: 30),
            _buildProductList(),
          ],
        ),
      ),
    );
  }

  // Search bar
  Widget _buildSearchBar() {
    return Container(
      width: 600,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: (value) => controller.applySearchFilter(value),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          hintText: "Search By Product ID or Name",
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
        ),
      ),
    );
  }

  // Zone dropdown
  Widget _buildZoneDropdown() {
    return Obx(() {
      if (controller.zones.isEmpty) {
        return Text("No Zones", style: TextStyle(color: Colors.grey));
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
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
                value: zone['zoneId'],
                child: Text(zone['zoneName'] ?? 'Unnamed Zone'),
              );
            }).toList(),
            onChanged: (newZoneId) {
              controller.onZoneChanged(newZoneId);
            },
          ),
        ),
      );
    });
  }

  // Add product & refresh buttons
  Widget _buildActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [GestureDetector(
        onTap: () async {
          bool canCreate = await controller.canCreateProduct();
          if (canCreate) {
            Get.to(() => AddNewProductPage());
          } else {
            Get.snackbar(
              "Permission Denied",
              "🚫 You do not have permission to create a product in this zone.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
        child: const Text(
          "+ Add Product",
          style: TextStyle(
            color: Colors.green,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

        const SizedBox(width: 20),
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.purple[900], size: 28),
          tooltip: "Refresh Products",
          onPressed: () async {
            await controller.fetchProductsByZone();
            Get.snackbar(
              "Refreshed",
              "Product list updated",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          },
        ),
      ],
    );
  }

  // Product list / grid
  Widget _buildProductList() {
    return Obx(() {
      if (controller.filteredProducts.isEmpty) {
        return const Center(
          child: Text(
            "No products found",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.3,
        ),
        itemCount: controller.filteredProducts.length,
        itemBuilder: (context, index) {
          final product = controller.filteredProducts[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductHeader(product, index),
                _buildProductInfo(product),
                Expanded(child: Container()),
                _buildEditButton(product),
              ],
            ),
          );
        },
      );
    });
  }

  // Product header with image and status
  Widget _buildProductHeader(product, int index) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          // GestureDetector(
          //   onTap: () => Get.to(() => UpdateProductPage(productId: product.id)),
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(12),
          //     child: Image.network(
          //       product.imageUrl,
          //       height: 100,
          //       width: 100,
          //       fit: BoxFit.cover,
          //       errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
          //     ),
          //   ),
          // ),
          GestureDetector(
            onTap: () {
              print("🟢 Tapped product: ${product.name}");
              Get.to(() => ProductDetailsPage(productName: product.name));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(product.imageUrl, height: 100, width: 100),
            ),
          ),


          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.restaurant_menu,
                      color: product.option ? Colors.green : Colors.red, size: 30),
                  const SizedBox(width: 10),
                  Icon(Icons.circle,
                      color: product.isLive ? Colors.green : Colors.red, size: 12),
                  const SizedBox(width: 4),
                  Text(product.isLive ? "Live" : "Offline",
                      style: TextStyle(
                          color: product.isLive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              Text("ID: ${product.id}",
                  style: TextStyle(color: Colors.purple[900], fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // Product details row
  Widget _buildProductInfo(product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoBox("${product.quantity}", "QTY"),
          _buildInfoBox("₹${product.sellerPrice}", "Seller Price"),
          _buildInfoBox("₹${product.sellingPrice}", "Selling Price"),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Edit button
  Widget _buildEditButton(product) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.deepPurpleAccent,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
      width: double.infinity,
      height: 50,
      child: TextButton.icon(
        onPressed: () async {
          bool canEdit = await controller.canEditProduct();
          if (canEdit) {
            Get.to(() => UpdateProductPage(productId: product.id),
                binding: BindingsBuilder(() {
                  Get.put(ShopController());  // inject here
                  Get.put(UpdateProductController(product.id));
                }));
          } else {
            Get.snackbar(
              "Permission Denied",
              "🚫 You do not have permission to update payment for this zone.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
        icon: const Icon(Icons.edit, color: Colors.white, size: 16),
        label: const Text("Edit", style: TextStyle(color: Colors.white)),
      ),
    );
  }

}
