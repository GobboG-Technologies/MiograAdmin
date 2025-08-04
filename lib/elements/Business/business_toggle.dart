import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/Business&sellerCon.dart';
import '../../controller/orderController.dart';
import '../../controller/productController.dart';


// Reusable Toggle Widget
class BusinessToggle extends StatelessWidget {
  final BusinessSellerController controller;

  BusinessToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Center(
      child: Container(
        width: MediaQuery.sizeOf(context).width/4,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _buildSegment("Products", 0, controller),
            _buildSegment("Requests", 1, controller),
          ],
        ),
      ),
    ));
  }

  Widget _buildSegment(String title, int index, BusinessSellerController controller) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.selectedTab.value = index;
        },
        child: Container(
          decoration: BoxDecoration(
            color: controller.selectedTab.value == index
                ? Color(0xFF5D348B)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: controller.selectedTab.value == index
                  ? Colors.white
                  : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
