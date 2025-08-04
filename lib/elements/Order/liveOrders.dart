import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controller/deliveryPersonCon.dart';
import '../../controller/liveOrderCOn.dart';
import '../../controller/orderController.dart';


class LiveListPage extends StatelessWidget {
  final LiveOrderController controller = Get.put(LiveOrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Search Bar
            Center(child: _buildSearchBar()),
            SizedBox(height: 30,),
            Expanded(
              child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 1200
                    ? 3 // 3 columns for larger screens
                    : (constraints.maxWidth > 800 ? 2 : 1); // Adjust for smaller screens

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio:0.85, // Adjust card aspect ratio
                  ),
                  itemCount:  controller.liveorders.length, // Dummy 6 orders
                  itemBuilder: (context, index) {
                    final order = controller.liveorders[index];
                    return LiveOrderCard(
                      order: order, index: index,
                    );
                  },
                );
              },
            ),)
          ],
        ),
      ),
    );
  }
  // Search Bar
  Widget _buildSearchBar() {
    return Container(
      width: 600,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          hintText: "Search By Order ID",
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
        ),
      ),
    );
  }
}


class LiveOrderCard extends StatelessWidget {
  final Map order;
  final int index;

  const LiveOrderCard({
    Key? key,
    required this.order, required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LiveOrderController controller = Get.find<LiveOrderController>();
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order details
            Text(
              "Order ID: ${order["id"]}",
              style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 14,color: Colors.grey),
            ),
            SizedBox(height:10),
            Center(
              child: Text(
                order["restaurant"],
                style:  TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 10.h),

            // Items list
            Column(
              children: List.generate(order["items"].length, (index) {
                final item = order["items"][index];
                return Row(
                  children: [
                    Image.network(
                      item['imageUrl'] ?? 'https://via.placeholder.com/150',
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),

                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item["name"],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                          Row(
                            children: [
                              Icon(
                                item["option"] == "veg" ? Icons.eco : Icons.restaurant_menu, // Icon for veg/non-veg
                                color: item["option"] == "veg" ? Colors.green : Colors.red, // Green for veg, red for non-veg
                                size: 20,
                              ),
                              Text(
                                "ID: ${item["id"]}",
                                style:  TextStyle(fontSize: 12, color: Colors.purple[900]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),

            SizedBox(height: 12.h),

            // Address
            Text("Address", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.purple[900],fontSize: 17)),
            SizedBox(height: 8),
            Text(
              order["address"],
              style:  TextStyle(fontSize: 15, color: Colors.grey[600],fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),

            // Payment details

            Row(
              children: [
                Image.asset(order["paymentMode"] == "COD" ? "assets/images/cod.png" :"assets/images/upi.png",
                  height: 25,width: 39 ,),
                SizedBox(width: 10,),
                if (order["paymentMode"] != "UPI") ...[
                  Row(
                    children: [
                      Icon(Icons.currency_rupee_sharp,color: Colors.purple[900],),
                      Text(order["amount"],
                        style: TextStyle(fontWeight: FontWeight.bold,color: Colors.purple[900],fontSize: 20),),
                    ],
                  ),
                ],
              ],
            ),

            SizedBox(height: 12),

            // Buttons
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order["time"],style: TextStyle(color: Colors.purple[900],fontWeight: FontWeight.bold,fontSize: 14),),
                    Text(order["date"],style: TextStyle(color: Colors.purple[900],fontWeight: FontWeight.bold,fontSize: 14)),
                  ],
                ),
                Spacer(),

                Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_searching,color: Color(0xFF5D348B),),
                        Text(order["address"],style: TextStyle(color: Colors.grey,fontSize: 14),),
                      ],
                    ),
                    SizedBox(height: 10),

                    Transform.rotate(
                      angle: 45 * (pi / 180), // Rotate the container by 45 degrees
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10), // Rounded edges
                        child: Container(
                          width: 40, // Increase size if needed
                          height: 40,
                          color: Color(0xFF5D348B),
                          child: Center(
                            child: Transform.rotate(
                              angle: -45 * (pi / 180), // Rotate back the icon
                              child: Icon(Icons.share, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.bike_scooter_outlined,color: Colors.purple[900],),
                SizedBox(width: 5,),
                Text(order["shopId"],style: TextStyle(color: Colors.purple[900],fontWeight: FontWeight.bold,fontSize: 14),),
              ],
            ),
          ],
        ),
      ),
    );
  }

}



