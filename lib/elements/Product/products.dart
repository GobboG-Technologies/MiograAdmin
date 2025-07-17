import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miogra_admin/elements/Product/addProduct.dart';
import '../../controller/productController.dart';
import 'dropdown.dart';

class ProductGrid extends StatelessWidget {
  final ProductController controller = Get.put(ProductController());

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
              Center(child: _buildSearchBar()),
              const SizedBox(height: 20),
              Center(child: FilterWidget()),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Get.to(() => AddNewProductPage()),
                child: Text(
                  "+ Add Product",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Obx(() => GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => showProductPopup(context, product, index, controller),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    product.imageUrl,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Icon(Icons.restaurant_menu, color: product.option ? Colors.green : Colors.red, size: 30),
                                      SizedBox(width: MediaQuery.of(context).size.width / 10),
                                      Icon(Icons.circle, color: product.isLive ? Colors.green : Colors.red, size: 12),
                                      const SizedBox(width: 4),
                                      Text(
                                        product.isLive ? "Live" : "Offline",
                                        style: TextStyle(
                                            color: product.isLive ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text("ID: ${product.id}",
                                      style: TextStyle(
                                          color: Colors.purple[900], fontSize: 15, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                    color: Colors.purple[900], borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text("${product.quantity}",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    const Text("QTY",
                                        style: TextStyle(
                                            color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                children: [
                                  Text("₹${product.sellerPrice}",
                                      style:
                                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Text("Seller Price",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                              Column(
                                children: [
                                  Text("₹${product.sellingPrice}",
                                      style:
                                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Text("Selling Price",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: Container()),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.purple[900],
                              borderRadius:
                              BorderRadius.vertical(bottom: Radius.circular(12))),
                          width: double.infinity,
                          height: 50,
                          child: TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                            label: const Text("Edit", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

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
}

void showProductPopup(BuildContext context, product, int index, ProductController controller) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width / 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl,
                  height: 230,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.restaurant_menu, color: product.option ? Colors.green : Colors.red, size: 30),
                  const Spacer(),
                  Text("ID: ${product.id}", style: TextStyle(color: Colors.purple[900])),
                ],
              ),
              const SizedBox(height: 10),
              Text(product.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                "Experience the authentic taste of South India with our delicious Idli, Vadai, Saambar, and Chutney combo. Perfect for breakfast, lunch, or dinner.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Obx(() => Row(
                children: [
                  GestureDetector(
                    onTap: () => controller.toggleLiveStatus(index),
                    child: Container(
                      width: 50,
                      height: 20,
                      decoration: BoxDecoration(
                        color: product.isLive ? Colors.green[200] : Colors.red[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: product.isLive
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              width: 20,
                              height: 20,
                              margin: EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: product.isLive ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 2),
                  Text(
                    product.isLive ? "Live" : "Offline",
                    style: TextStyle(
                      color: product.isLive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.orange, width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: Text(
                      "Close",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange),
                    ),
                  )
                ],
              )),
            ],
          ),
        ),
      ),
    ),
  );
}
