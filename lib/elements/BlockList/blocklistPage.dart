import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miogra_admin/elements/BlockList/blockBusinessPage.dart';
import 'package:miogra_admin/elements/BlockList/blockProductPage.dart';

import '../../controller/BlockDashboardController.dart';
import 'BlockSellerPage.dart';
import 'blockDeliveryPage.dart';

class BlockDashboardPage extends StatelessWidget {
  final BlockDashboardController controller =
  Get.put(BlockDashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTabs(context),
            const SizedBox(height: 20),
            _buildFilters(),
            const SizedBox(height: 20),

            /// 🔹 Dynamic child page
            Expanded(
              child: Obx(() {
                switch (controller.selectedTab.value) {
                  case "Seller":
                    return blockSellerPage();
                  case "Business":
                    return blockBusinessPage();
                  case "Product":
                    return blockProductPage();
                  case "Delivery":
                    return blockDeliveryPage();
                  default:
                    return const Center(child: Text("Select a tab"));
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Obx(() => Center(
      child: Container(
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ["Seller", "Business", "Product", "Delivery"]
              .map((tab) => GestureDetector(
            onTap: () => controller.changeTab(tab),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 60),
              decoration: BoxDecoration(
                color: controller.selectedTab.value == tab
                    ? Colors.purple[900]
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  color: controller.selectedTab.value == tab
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ))
              .toList(),
        ),
      ),
    ));
  }

  Widget _buildFilters() {
    return Obx(() {
      bool isBusinessTab = controller.selectedTab.value == "Business";

      return Row(
        children: [
          // 🔹 Zone Dropdown (Dynamic)
          Obx(() {
            if (controller.zones.isEmpty) {
              return const Text("No Zones");
            }
            return Container(
              width: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[300],
              ),
              child: DropdownButtonFormField<String>(
                value: controller.selectedZoneId.value,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  border: InputBorder.none,
                ),
                items: controller.zones.map((zone) {
                  return DropdownMenuItem<String>(
                    value: zone['zoneId'] as String,
                    child: Text(zone['zoneName'] as String),
                  );
                }).toList(),
                onChanged: (value) => controller.onZoneChanged(value),
              ),
            );
          }),

          const SizedBox(width: 16),

          // 🔹 Business-specific Dropdown
          if (isBusinessTab)
            Container(
              width: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[300],
              ),
              child: DropdownButtonFormField<String>(
                value: controller.selectedCategory.value,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                items: ["Category A", "Category B", "Category C"]
                    .map((cat) =>
                    DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) =>
                controller.selectedCategory.value = value!,
              ),
            ),

          const SizedBox(width: 16),

          // 🔹 Filter Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D348B),
              padding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
            ),
            onPressed: () {
              // TODO: apply filters based on selectedZoneId + selectedCategory
            },
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
            label:
            const Text("Filter", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    });
  }
}
