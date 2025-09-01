import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/blockBusinessController.dart';


class blockBusinessPage extends StatelessWidget {
  final blockBusinessController controller = Get.put(blockBusinessController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Businesses"),
        backgroundColor: Colors.green,
        actions: [
          // Obx(() => DropdownButton<String>(
          //   value: controller.selectedZoneId.value,
          //   hint: const Text("Select Zone"),
          //   items: controller.zones.map((zone) {
          //     return DropdownMenuItem<String>(
          //       value: zone['zoneId'],
          //       child: Text(zone['zoneName']),
          //     );
          //   }).toList(),
          //   onChanged: (newValue) {
          //     controller.onZoneChanged(newValue);
          //   },
          // )),
        ],
      ),
      body: Obx(() {
        // if (controller.businesses.isEmpty) {
        //   return const Center(child: Text("No businesses found."));
        // }
        return ListView.builder(
          // itemCount: controller.businesses.length,
          itemBuilder: (context, index) {
            // final business = controller.businesses[index];
            // return Card(
            //   margin: const EdgeInsets.all(8),
            //   child: ListTile(
            //     leading: const Icon(Icons.store, color: Colors.green),
            //     title: Text(business.name),
            //     subtitle: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text("Owner: ${business.ownerName}"),
            //         Text("Phone: ${business.phone}"),
            //         Text("Zone: ${business.zoneId}"),
            //       ],
            //     ),
            //     trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            //   ),
            // );
          },
        );
      }),
    );
  }
}
