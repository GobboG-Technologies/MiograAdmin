import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../admin/announcement.dart';
import '../../admin/commisisons.dart';
import '../../admin/termsandcondition.dart';
import '../../controller/LoginController.dart';
import '../../controller/dashboardController.dart';
import '../../example.dart';

class DashboardTopBar extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());
  final LoginController loginController = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side Empty or Logo can come here if needed
          SizedBox(),

          // Right Side - Dropdown + Icons
          Row(
            children: [
              // Dropdown

              SizedBox(width: 10), // spacing between dropdown and first icon

              // Icons
              _topBarIcon(LucideIcons.lamp, Colors.red,
                  // onTap: () => Get.to(() => UserFormPage())
              ),
              Obx(() => _topBarIcon(
                LucideIcons.alarmClock,
                controller.hasAlarm.value ? Colors.red : Colors.black,
                onTap: controller.toggleAlarm,
              )),
              _topBarIcon(LucideIcons.badgeCheck, Colors.black,
                  // onTap: () => Get.to(() => UserFormPage())
                  onTap: loginController.logout
              ),
              _topBarIcon(LucideIcons.userSquare, Colors.black,
                  // onTap: () => Get.to(() => CommissionGSTPage())
                  onTap: loginController.logout
              ),
              _topBarIcon(LucideIcons.megaphone, Colors.black,
                  // onTap: () => Get.to(() => AnnouncementPage())
                  onTap: loginController.logout
              ),
              _topBarIcon(
                LucideIcons.logOut,
                Colors.black,
                onTap: loginController.logout, // Call logout
              ),


              // Obx(() => SizedBox(
              //   width: 200,
              //   height: 50,
              //   child: DecoratedBox(
              //     decoration: BoxDecoration(
              //       color: Color(0xFF7B5BA6),
              //       borderRadius: BorderRadius.circular(8), // Dropdown button radius
              //     ),
              //     child: DropdownButtonHideUnderline(
              //       child: DropdownButton<String>(
              //         value: controller.selectedZone.value.isNotEmpty
              //             ? controller.selectedZone.value
              //             : null,
              //         hint: Padding(
              //           padding: const EdgeInsets.symmetric(horizontal: 8),
              //           child: Row(
              //             children: [
              //               Icon(Icons.interests_outlined, color: Colors.white, size: 24),
              //               SizedBox(width: 8),
              //               Text("Modules", style: TextStyle(color: Colors.white)),
              //             ],
              //           ),
              //         ),
              //         dropdownColor: Color(0xFFF4F2F2),
              //         icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
              //         style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
              //         onChanged: (String? newValue) {
              //           if (newValue != null) {
              //             controller.setZone(newValue);
              //           }
              //         },
              //         items: [
              //           {'label': 'FOOD', 'icon': Icons.fastfood,'color':Colors.amber},
              //           {'label': 'FRESH CUT', 'icon': Icons.add_chart_rounded,'color':Colors.cyan},
              //           {'label': 'PHARMACY', 'icon': Icons.local_hospital,'color':Colors.pink},
              //           {'label': 'DAILY MIO', 'icon': Icons.rice_bowl,'color':Colors.green},
              //         ].map((item) {
              //           return DropdownMenuItem<String>(
              //             value: item['label'] as String,
              //             child: Container(
              //               margin: EdgeInsets.only(left: 20.0), // <-- Add margin here (adjust 20.0 as needed)
              //               decoration: BoxDecoration(
              //                 color: Colors.purple[100], // Background per item (optional)
              //                 borderRadius: BorderRadius.circular(8), // Rounded item
              //               ),
              //               padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              //               child: Row(
              //                 children: [
              //                   Icon(item['icon'] as IconData, size: 20, color: Colors.purple),
              //                   SizedBox(width: 10),
              //                   Text(item['label'] as String),
              //                 ],
              //               ),
              //             ),
              //           );
              //         }).toList(),
              //       ),
              //     ),
              //   ),
              // ))


            ],
          ),
        ],
      ),
    );
  }

  // Icon Widget with Tap Functionality
  Widget _topBarIcon(IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
