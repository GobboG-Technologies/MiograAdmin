import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp

// Your controllers
import '../../controller/deliveryPersonCon.dart';
import '../../controller/orderController.dart';

class OrderListPage extends StatelessWidget {
  // GetX will find or create the OrderController instance
  final OrderController controller = Get.put(OrderController());

  OrderListPage({super.key});
  // controller.orders
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(child: _buildSearchBar()),
            const SizedBox(height: 30),
            Expanded(
              child: Obx(() {
                if (controller.orders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("Loading Orders..."),
                      ],
                    ),
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 1200
                        ? 3
                        : (constraints.maxWidth > 800 ? 2 : 1);

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: controller.filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = controller.filteredOrders[index];
                        // <-- change here
                        return RequestOrderCard(order: order, index: index);
                      },
                    );
                  },
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final controller = Get.find<OrderController>();
    return Container(
      width: 600,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        onChanged: (value) => controller.searchQuery.value = value,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          hintText: "Search By Order ID",
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
        ),
      ),
    );
  }

}

class RequestOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final int index;

  const RequestOrderCard({
    Key? key,
    required this.order,
    required this.index,
  }) : super(key: key);

  String _formatTimestamp(dynamic timestamp, String format) {
    if (timestamp is! Timestamp) return "N/A";
    try {
      return DateFormat(format).format(timestamp.toDate());
    } catch (e) {
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.find<OrderController>();
    final List items = order["items"] as List? ?? [];
    final bool isCOD = (order["paymentId"] == null || (order["paymentId"] as String).isEmpty);
    final String shopName = order["shopName"] ?? (items.isNotEmpty ? items[0]['shopName'] ?? 'Unknown Shop' : 'Unknown Shop');

    // FIX: Compute address outside widget tree
    final addressMap = order["deliveryAddress"] ?? {};
    final addressText = [
      addressMap["house Name"],
      addressMap["landmark"],
      addressMap["city"],
      addressMap["fullAddress"],
    ].where((e) => e != null && e.toString().isNotEmpty && e.toString() != "null").join(", ");

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Order ID: ${order["docId"] ?? 'N/A'}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  shopName,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 10),
              if (items.isNotEmpty)
                ...items.map((item) {
                  final bool isVeg = (item["foodType"] as String?)?.toLowerCase() == "veg";
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            item["imageUrl"] ?? '',
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 60,
                              width: 60,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["productName"] ?? 'Unnamed Product',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.circle, color: isVeg ? Colors.green : Colors.red, size: 14),
                                  const SizedBox(width: 4),
                                  Text(isVeg ? "Veg" : "Non-Veg", style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text("x ${item['count'] ?? 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),

              const SizedBox(height: 12),

              Text("Address", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple[900], fontSize: 17)),
              const SizedBox(height: 8),
              Text(
                addressText.isEmpty ? 'Address not available in database' : addressText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    isCOD ? "assets/images/cod.png" : "assets/images/upi.png",
                    height: 25,
                    width: 39,
                  ),
                  Row(
                    children: [
                      Icon(Icons.currency_rupee_sharp, color: Colors.purple[900]),
                      Text(
                        (order["totalPrice"] ?? 0).toStringAsFixed(2),
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple[900], fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatTimestamp(order["timestamp"], 'MMM d, yyyy'),
                        style: TextStyle(color: Colors.purple[900], fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        _formatTimestamp(order["timestamp"], 'h:mm a'),
                        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Assign button (commented out, enable if needed)
                  // ElevatedButton(
                  //   onPressed: () => _showAssignDialog(context, index),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: const Color(0xFF5D348B),
                  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  //   ),
                  //   child: const Text("Assign", style: TextStyle(color: Colors.white)),
                  // )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _showAssignDialog(BuildContext context, int orderIndex) {
  //   final deliveryController = Get.put(DeliveryPersonController());
  //   final OrderController controller = Get.find<OrderController>();
  //
  //   Get.dialog(
  //     Dialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //       child: Container(
  //         width: MediaQuery.of(context).size.width * 0.4,
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Text("Select Delivery Person", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //             const SizedBox(height: 10),
  //             const Divider(),
  //             SizedBox(
  //               height: deliveryController.deliveryPersons.length > 6 ? 300 : null,
  //               child: SingleChildScrollView(
  //                 child: Column(
  //                   children: List.generate(deliveryController.deliveryPersons.length, (index) {
  //                     var person = deliveryController.deliveryPersons[index];
  //                     return Obx(() {
  //                       return ListTile(
  //                         leading: Row(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: [
  //                             CircleAvatar(
  //                               radius: 8,
  //                               backgroundColor: deliveryController.deliveryPersons[index].isAvailable.value
  //                                   ? Colors.green
  //                                   : Colors.red,
  //                             ),
  //                             const SizedBox(width: 8),
  //                             ClipRRect(
  //                               borderRadius: BorderRadius.circular(8),
  //                               child: Image.network(
  //                                 person.imageUrl ?? "https://via.placeholder.com/60",
  //                                 width: 60,
  //                                 height: 60,
  //                                 fit: BoxFit.cover,
  //                                 errorBuilder: (context, error, stackTrace) => Container(
  //                                   width: 60,
  //                                   height: 60,
  //                                   color: Colors.grey.shade200,
  //                                   child: const Icon(Icons.image_not_supported, color: Colors.grey),
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                         title: Text(person.name, style: const TextStyle(fontWeight: FontWeight.bold)),
  //                         subtitle: Text("ID: ${person.id}", style: const TextStyle(color: Color(0xFF5D348B))),
  //                         trailing: Radio<int>(
  //                           value: index,
  //                           groupValue: deliveryController.selectedPerson.value,
  //                           onChanged: person.isAvailable.value ? (value) => deliveryController.selectedPerson.value = value : null,
  //                           activeColor: const Color(0xFF5D348B),
  //                         ),
  //                       );
  //                     });
  //                   }),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 15),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 ElevatedButton(
  //                   onPressed: () => Get.back(),
  //                   style: ElevatedButton.styleFrom(
  //                     side: const BorderSide(color: Colors.orange),
  //                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //                   ),
  //                   child: const Text("Close", style: TextStyle(color: Colors.orange)),
  //                 ),
  //                 ElevatedButton(
  //                   onPressed: () {
  //                     // if (deliveryController.selectedPerson.value != null) {
  //                     //   controller.assignedOrders[orderIndex] =
  //                     //       deliveryController.deliveryPersons[deliveryController.selectedPerson.value!].name;
  //                     //   Get.back();
  //                     // }
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: const Color(0xFF5D348B),
  //                     disabledForegroundColor: Colors.white.withOpacity(0.6),
  //                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //                   ),
  //                   child: const Text("Assign", style: TextStyle(color: Colors.white)),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
