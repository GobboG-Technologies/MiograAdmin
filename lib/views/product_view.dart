import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/orderController.dart';
import '../controller/productController.dart';
import '../elements/Order/liveOrders.dart';
import '../elements/Order/orderReqPage.dart';
import '../elements/Order/orderappbar.dart';
import '../elements/Order/togglebutton.dart';
import '../elements/Product/RequestProductGrid.dart';
import '../elements/Product/dropdown.dart';
import '../elements/Product/product_toggle.dart';
import '../elements/Product/products.dart';
import '../example.dart';



class ProductPage extends StatelessWidget {
  final ProductController controller = Get.put(ProductController());

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
            ProductToggle(controller: controller),
            const SizedBox(height: 30),

            // Content Based on Selection
            Obx(() {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.7, // Adjust height to prevent overflow
                child: controller.selectedTab.value == 0
                    ? ProductGrid()
                    : RequestProductGrid(),
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
