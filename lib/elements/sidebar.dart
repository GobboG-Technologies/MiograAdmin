import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../controller/navigationController.dart';


class Sidebar extends StatelessWidget {
  final SidebarController controller = Get.put(SidebarController());

  final List<Map<String, dynamic>> menuItems = [
    {"icon": LucideIcons.barChart, "title": "Dashboard"},
    {"icon": LucideIcons.box, "title": "Orders"},
    {"icon": LucideIcons.package, "title": "Product"},
    {"icon": LucideIcons.building, "title": "Business"},
    {"icon": LucideIcons.user, "title": "Seller"},
    {"icon": LucideIcons.truck, "title": "Delivery"},
    {"icon": LucideIcons.users, "title": "Customer"},
    {"icon": LucideIcons.image, "title": "Banner"},
    {"icon": LucideIcons.hash, "title": "Block List"},
    {"icon": LucideIcons.indianRupee, "title": "Payment"},
    {"icon": LucideIcons.shield, "title": "Admins"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Color(0xFF5D348B), // Purple background
        borderRadius: BorderRadius.circular(15), // Circular right edge
        ),

      child: Column(
        children: [
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return Obx(() {
                  bool isSelected = controller.selectedIndex.value == index;
                  return GestureDetector(
                    onTap: () => controller.changePage(index),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            Icon(menuItems[index]["icon"],
                                color: isSelected ? Color(0xFF5D348B) : Colors.white, size: 26),
                            SizedBox(width: 10),
                            Text(
                              menuItems[index]["title"],
                              style: TextStyle(
                                color: isSelected ? Color(0xFF5D348B) : Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 26
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
