import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/navigationController.dart';
import '../elements/sidebar.dart';

class DashboardScreen extends GetView<SidebarController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Obx(() => controller.pages[controller.selectedIndex.value]),
          ),
        ],
      ),
    );
  }
}
