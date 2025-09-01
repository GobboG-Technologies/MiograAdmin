import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/ProductDetailsController.dart';

class ProductDetailsPage extends StatelessWidget {
  final String productName;

  const ProductDetailsPage({Key? key, required this.productName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProductDetailsController controller =
    Get.put(ProductDetailsController(productName));

    return Scaffold(
      appBar: AppBar(
        title: Text("Product Details"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.productData.isEmpty) {
          return const Center(child: Text("No product details found"));
        }

        final product = controller.productData;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product['imageUrl'] ?? '',
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) =>
                    const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Product Info
              Text(product['productName'] ?? '',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),
              Text("Description: ${product['description'] ?? ''}"),
              Text("Food Type: ${product['foodType'] ?? ''}"),
              Text("Main Category: ${product['mainCategory'] ?? ''}"),
              Text("Sub Category: ${product['subCategory'] ?? ''}"),
              const SizedBox(height: 10),
              Text("Price: ₹${product['productPrice'] ?? ''}"),
              Text("Your Price: ₹${product['yourprice'] ?? ''}"),
              Text("Quantity: ${product['productQty'] ?? ''}"),
              Text("Status: ${product['status'] ?? ''}"),
              Text("Product Status: ${product['productStatus'] ?? ''}"),
              const SizedBox(height: 10),
              Text("Shop: ${product['shopName'] ?? ''}"),
              Text("Delivery Zone: ${product['deliveryzone'] ?? ''}"),
              Text("Zone Name: ${product['deliveryzonename'] ?? ''}"),
              const SizedBox(height: 10),
              Text("Timestamp: ${product['timestamp'] ?? ''}"),
            ],
          ),
        );
      }),
    );
  }
}
