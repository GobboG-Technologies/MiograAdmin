import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/Business&sellerCon.dart';
import '../controller/orderController.dart';
import '../controller/productController.dart';
import '../elements/Business/BusinessReq.dart';
import '../elements/Business/businessPage.dart';
import '../elements/Business/business_toggle.dart';
import '../elements/Order/liveOrders.dart';
import '../elements/Order/orderReqPage.dart';
import '../elements/Order/orderappbar.dart';
import '../elements/Order/togglebutton.dart';
import '../elements/Product/RequestProductGrid.dart';
import '../elements/Product/dropdown.dart';
import '../elements/Product/product_toggle.dart';
import '../elements/Product/products.dart';
import '../example.dart';


class BusinessPage extends StatelessWidget {
  final BusinessSellerController controller = Get.put(BusinessSellerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:   Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //appbar
            OrderTopBar(),
            const SizedBox(height: 20),
            // Toggle Button Container
            BusinessToggle(controller: controller),
            const SizedBox(height: 30),

            // Content Based on Selection
            Obx(() {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: controller.selectedTab.value == 0
                    ? BusinessGrid()
                    : RequestBusinessGrid(),
              );
            }),

            // // Content Based on Selection
            // Expanded(
            //   child: Obx(() {
            //     return controller.selectedTab.value == 0
            //         ? ProductGrid()
            //         : RequestProductGrid();
            //   }),
            // ),
          ],
        ),
      ),
    );
  }

}
