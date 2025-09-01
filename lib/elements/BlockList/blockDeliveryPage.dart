import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/blockDeliveryController.dart';

class blockDeliveryPage extends StatelessWidget {
  final blockDeliveryController controller = Get.put(blockDeliveryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery Boys"),
        backgroundColor: Colors.green,
        actions: [

        ],
      ),

    );
  }
}
