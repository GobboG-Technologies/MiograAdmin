import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../controller/RequestProductCon.dart';
import 'RequestProduct.dart';

class RequestProductGrid extends StatelessWidget {
  final RequestProductController controller = Get.put(RequestProductController());

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3-column layout
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.6, // Adjust based on design
        ),
        itemCount: controller.products.length,
        itemBuilder: (context, index) {
          return RequestProductCard(
            product: controller.products[index],
            index: index,
            controller: controller,
          );
        },
      ),
    );
  }
}