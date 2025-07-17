import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/orderController.dart';
import '../elements/Banner/BannerPage.dart';
import '../elements/BlockList/blocklistPage.dart';
import '../elements/Customer/cutomerPage.dart';
import '../elements/Delivery/deliveryPage.dart';
import '../elements/Order/orderappbar.dart';
import '../elements/admin/adminPage.dart';

class BlockListViewPage extends StatelessWidget {
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
            SizedBox(height: 70),
            // Content
            Expanded(
              child: BlockDashboardPage(),
            ),
          ],
        ),
      ),
    );
  }

}
