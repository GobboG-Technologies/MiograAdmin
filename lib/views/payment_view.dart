import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miogra_admin/controller/paymentController.dart';
import '../controller/orderController.dart';
import '../elements/Business/business_dropdown.dart';
import '../elements/Order/liveOrders.dart';
import '../elements/Order/orderReqPage.dart';
import '../elements/Order/orderappbar.dart';
import '../elements/Order/togglebutton.dart';
import '../elements/payment/paymentDeliveryHistory.dart';
import '../elements/payment/paymentFloatingPage.dart';
import '../elements/payment/paymentPage.dart';
import '../elements/payment/togglebutton.dart';
import '../example.dart';



class PaymentViewPage extends StatelessWidget {
  final paymentController controller = Get.put(paymentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //appbar
            OrderTopBar(),
             SizedBox(height: 20),
            // Toggle Button Container
            PaymentToggle(controller: controller),
             SizedBox(height: 20),
            // Search Bar
            Center(child: _buildSearchBar()),
             SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FilterWidget(),
              ],
            ),
            SizedBox(height: 50),
            // Content Based on Selection
            Expanded(
              child: Obx(() {
                switch (controller.selectedTab.value) {
                  case 0:
                    return PaymentHistoryPage();
                  case 1:
                    return PaymentDeliveryHistoryPage();
                  case 2:
                    return PaymentFloatingPage(); // Your third page
                  default:
                    return Center(child: Text("Invalid Tab"));
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Search Bar
  Widget _buildSearchBar() {
    return Container(
      width: 600,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          hintText: "Search Here",
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
        ),
      ),
    );
  }

}
