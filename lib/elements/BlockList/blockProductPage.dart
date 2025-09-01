import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/blockProductController.dart';

class blockProductPage extends StatelessWidget {
  final blockProductController controller = Get.put(blockProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        backgroundColor: Colors.blue,
        actions: [
          Obx(() => DropdownButton<String>(
            value: controller.selectedZoneId.value,
            hint: const Text("Select Zone"),
            items: controller.zones.map((zone) {
              return DropdownMenuItem<String>(
                value: zone['zoneId'],
                child: Text(zone['zoneName']),
              );
            }).toList(),
            onChanged: (newValue) {
              controller.onZoneChanged(newValue);
            },
          )),
        ],
      ),
      body: Obx(() {
        if (controller.products.isEmpty) {
          return const Center(child: Text("No products found."));
        }
        return ListView.builder(
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: product.imageUrl.isNotEmpty
                    ? Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.shopping_bag, color: Colors.blue),
                title: Text(product.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Category: ${product.category}"),
                    Text("Price: ₹${product.price}"),
                    Text("Zone: ${product.zoneId}"),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            );
          },
        );
      }),
    );
  }
}
