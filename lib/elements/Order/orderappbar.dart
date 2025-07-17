import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../admin/announcement.dart';
import '../../admin/commisisons.dart';
import '../../admin/termsandcondition.dart';
import '../../controller/dashboardController.dart';
import '../../example.dart';

class OrderTopBar extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),

      child:
          // Right Side - Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(() => _topBarIcon(
                LucideIcons.alarmClock,
                controller.hasAlarm.value ? Colors.red : Colors.black,
                onTap: controller.toggleAlarm, // Toggle alarm state on tap
              )),
              _topBarIcon(LucideIcons.badgeCheck, Colors.black,onTap: () => Get.to(() => UserFormPage())),
              _topBarIcon(LucideIcons.userSquare, Colors.black,onTap: () => Get.to(() => CommissionGSTPage())),
              _topBarIcon(LucideIcons.megaphone, Colors.black,onTap: () => Get.to(() => AnnouncementPage())),
              _topBarIcon(LucideIcons.logOut, Colors.black),
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
