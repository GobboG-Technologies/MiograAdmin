import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/RequestProductCon.dart';
import 'RequestProduct.dart';


class RequestProductGrid extends StatelessWidget {
  final RequestProductController controller = Get.put(RequestProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pending Products")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Zone Dropdown
            Obx(() {
              if (controller.zones.isEmpty) return const Text("No Zones available");
              return DropdownButton<String>(
                value: controller.selectedZoneId.value,
                hint: const Text("Select Zone"),
                items: controller.zones.map((zone) {
                  return DropdownMenuItem<String>(
                    value: zone['zoneId'],
                    child: Text(zone['zoneName'] ?? 'Unnamed Zone'),
                  );
                }).toList(),
                onChanged: controller.onZoneChanged,
              );
            }),
            const SizedBox(height: 20),

            // Product Grid
            Expanded(
              child: Obx(() {
                if (controller.products.isEmpty) {
                  return const Center(child: Text("No products found"));
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    return RequestProductCard(
                      product: controller.products[index],
                      index: index,
                      controller: controller,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
