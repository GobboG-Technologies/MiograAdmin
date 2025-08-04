import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/orderHistoryController.dart';

class OrderPreviewPage extends StatelessWidget {
  final OrderHistoryController controller = Get.find<OrderHistoryController>();

  @override
  Widget build(BuildContext context) {
    final order = controller.selectedOrder;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Container(
          width: 400,
          height: MediaQuery.of(context).size.height/1.2,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Text(
                'Order ID: ${order['orderId']}',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 10),
              Text(
                order['shopName'],
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              // Items List
              SizedBox(height: 20),
              ...order['items'].map<Widget>((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(item['image'], width: 60, height: 60),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'], style: TextStyle(fontSize: 16)),
                          Text('ID: ${item['id']}', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),

              // Business and Delivery Addresses
              SizedBox(height: 20),
              Text('Business Address', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple[900])),
              Text(order['businessAddress']),
              SizedBox(height: 12),
              Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple[900])),
              Text(order['deliveryAddress']),

              // Time, Amount, and Payment
              SizedBox(height: 20),
              Row(
                children: [
                  Column(
                    children: [
                      Text(order['time'], style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.purple[900])),
                      Text(order['date'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color: Colors.purple[900])),
                    ],
                  ),

                  Spacer(),
                  Column(
                    children: [
                      Text(order['amount'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(order['paymentMethod'], style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                ],
              ),

              // Shop ID
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.store_mall_directory, color: Colors.purple[900]),
                  SizedBox(width: 8),
                  Text(order['shopId'], style: TextStyle(color: Colors.purple[900])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
