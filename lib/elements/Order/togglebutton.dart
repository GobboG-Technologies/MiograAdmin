import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/orderController.dart';


// Reusable Toggle Widget
class OrderToggle extends StatelessWidget {
  final OrderController controller;

  OrderToggle({required this.controller});

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
            _buildSegment("Order Request", 0, controller),
            _buildSegment("Live Orders", 1, controller),
            _buildSegment("History", 2, controller),
          ],
        ),
      ),
    ));
  }

  Widget _buildSegment(String title, int index, OrderController controller) {
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
