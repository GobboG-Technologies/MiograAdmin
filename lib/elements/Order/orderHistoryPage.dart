import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../controller/orderHistoryController.dart';
import '../../example.dart';
import 'orderPreview.dart';

class HistoryPage extends StatelessWidget {
  final OrderHistoryController controller = Get.put(OrderHistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 10,
            border: TableBorder.all(color: Colors.black),
            columns: [
              DataColumn(label: Text('NO')),
              DataColumn(label: Text('Order ID')),
              DataColumn(label: Text('Customer Email')),
              DataColumn(label: Text('Business ID')),
              DataColumn(label: Text('Delivery')),
              DataColumn(label: Text('Delivered Time')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Commission')),
              DataColumn(label: Text('Incentive')),
              DataColumn(label: Text('GST')),
              DataColumn(label: Text('Delivery Charge')),
              DataColumn(label: Text('Action')),
            ],
            rows: List.generate(controller.historyData.length, (index) {
              final data = controller.historyData[index];
              return DataRow(cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(Text(data['orderId'])),
                DataCell(Text(data['email'])),
                DataCell(Text(data['businessId'])),
                DataCell(Text(data['delivery'])),
                DataCell(Text(data['deliveredTime'])),
                DataCell(Text(data['amount'])),
                DataCell(Text(data['commission'])),
                DataCell(Text(data['incentive'])),
                DataCell(Text(data['gst'])),
                DataCell(Text(data['deliveryCharge'])),
                DataCell(ElevatedButton(
                  onPressed: () {
                    controller.setSelectedOrder(data);
                    Get.to(() => OrderPreviewPage());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Preview', style: TextStyle(color: Colors.white)),
                )),
              ]);
            }),
          ),
        )),
      ),
    );
  }
}