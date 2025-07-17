import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/orderController.dart';
import '../elements/Business/business_dropdown.dart';
import '../elements/Delivery/deliveryPage.dart';
import '../elements/Order/liveOrders.dart';
import '../elements/Order/orderReqPage.dart';
import '../elements/Order/orderappbar.dart';
import '../elements/Order/togglebutton.dart';
import '../elements/Seller/seller_page.dart';
import '../example.dart';

class DeliveryViewPage extends StatelessWidget {
  final OrderController controller = Get.put(OrderController());

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
             SizedBox(height: 50),
            // Search Bar
            const SizedBox(height: 20),
            // Content Based on Selection
            Expanded(
              child:  DeliveryCardPage(),
            ),
          ],
        ),
      ),
    );
  }

}
