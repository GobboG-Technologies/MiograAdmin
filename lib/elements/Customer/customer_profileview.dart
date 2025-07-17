
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../Models/CustomerModel.dart';
import '../../controller/customer_controller.dart';
import '../../example.dart';

class CustomerOrdersPage extends StatelessWidget {
  final Customer customer; // Accept selected customer

  CustomerOrdersPage({required this.customer});

  final CustomerControllerpage controller = Get.put(CustomerControllerpage());

  @override
  Widget build(BuildContext context) {
    // Filter orders for the selected customer
    final customerOrders = controller.customerOrder.where((order) => order.customerId == customer.id).toList();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body:SingleChildScrollView(
          child:  Center(
            child: Container(
              width: 400, // Adjust width for web layout
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child:
              // Obx(() {
              //   final customer = controller.customer.first; // Get first customer
              //   return
                  Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile Section
                  CircleAvatar(radius: 50, backgroundImage: AssetImage(customer.image)),
                  const SizedBox(height: 10),
                  Text(customer.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("+91${customer.phone}", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(customer.email, style: TextStyle(color: Colors.grey[600], fontSize: 16)),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    child:  Text("Close", style: TextStyle(color: Colors.orange)),
                  ),

                  const SizedBox(height: 15),
                  // Orders List
                customerOrders.isEmpty
                ? Text("No Orders Found", style: TextStyle(color: Colors.red, fontSize: 16))
                    :  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount:  customerOrders.length,
                    itemBuilder: (context, index) {
                      final Customerorder = customerOrders[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Order ID
                            Row(
                              children: [
                                Icon(Icons.circle, color: Customerorder.status == "Live" ? Colors.orange : Colors.green, size: 10),
                                const SizedBox(width: 5),
                                Text("Order ID: ${Customerorder.orderId}", style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 5),
                            // Price
                            Text("₹ ${Customerorder.price}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple[900])),
                            const SizedBox(height: 5),
                            // Time and Date
                            Row(
                              children: [
                                Text(Customerorder.time, style: TextStyle(color: Colors.purple[900], fontSize: 14)),
                                Spacer(),
                                Text(Customerorder.date, style: TextStyle(color: Colors.purple[900], fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 5),
                            // Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  Customerorder.status,
                                  style: TextStyle(
                                    color: Customerorder.status == "Live" ? Colors.orange : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Payment Method (COD or UPI)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Customerorder.paymentMethod == "COD" ? Colors.blue[100] : Colors.green[100],
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    Customerorder.paymentMethod, // Show "COD" or "UPI"
                                    style: TextStyle(
                                      color: Customerorder.paymentMethod == "COD" ? Colors.blue[900] : Colors.green[900],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              //);
  //}
  )
            ),
          )),
    );
  }
}