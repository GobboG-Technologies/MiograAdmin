import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:miogra_admin/elements/Dashboard/deliveryWidget.dart';
import 'package:miogra_admin/elements/Dashboard/productWidget.dart';

import '../controller/dashboardController.dart';
import '../elements/Dashboard/BusinessWidget.dart';
import '../elements/Dashboard/dashboard_appbar.dart';
import '../elements/Dashboard/order_list.dart';
import '../elements/Dashboard/sellerWidget.dart';
import '../elements/Dashboard/status_card.dart';

class DashboardView extends StatelessWidget {
  get selectedZone => null;
  final DashboardController controller = Get.put(DashboardController());
  final OrdersController ordersController = Get.put(OrdersController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardTopBar(),
           SizedBox(height: 20.h),
            Obx(() => Wrap(
              spacing: 40,
              runSpacing: 80,
              children: controller.stats.map((stat) {
                return StatsCard(
                  title: stat["title"] as String,
                  count: stat["count"] as String,
                  color: stat["color"] as Color,
                  icons: stat["icons"] as IconData,
                );
              }).toList(),
            )),
           SizedBox(height: 60),

          Text("Latest Order Request", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          SizedBox(height: 20),

          // 📌
          Container(
            height: 400,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1)],
            ),
            child: SingleChildScrollView(
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(), // Prevent double scrolling
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two columns layout
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 30,
                  childAspectRatio: 5.5, // Adjust for better layout
                ),
                itemCount: ordersController.orders.length,
                itemBuilder: (context, index) {
                  var order = ordersController.orders[index];
                  return OrderCard(
                    orderId: order["orderId"] as String,
                    amount: order["amount"] as String ,
                    date: order["date"] as String,
                    location: order["location"] as String,
                    paymentMethod: order["paymentMethod"] as String,
                  );
                },
              ),
            ),
          ),
      SizedBox(height: 80,),

          Row(
            children: [
              Expanded(child:  Text(
                "Recently Added Business",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),),
              Expanded(child:  Text(
                "Recently Joined Sellers",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),)
            ],
          ),
          SizedBox(height: 20),

      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              height: 400,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1)],
              ),
              child: SingleChildScrollView(
              child: BusinessList())),),
          SizedBox(width: 16),
          Expanded(
                 child: Container(
                 height: 400,
                  width: MediaQuery.of(context).size.width,
                     padding: EdgeInsets.all(10),
                     decoration: BoxDecoration(
                       color: Colors.grey.shade200,
                         borderRadius: BorderRadius.circular(12),
                         boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1)],
                 ),
                  child: SingleChildScrollView(
                      child: SellerList()))
            ),
          ]
      ),

          SizedBox(height: 80,),

          Row(
            children: [
              Expanded(child:  Text(
                "Recently Added Products",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),),
              Expanded(child:  Text(
                "Recently Joined Delivery Person",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),)
            ],
          ),
          SizedBox(height: 20),

          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                      height: 400,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1)],
                      ),
                      child: SingleChildScrollView(
                          child: ProductList())),),
                SizedBox(width: 16),
                Expanded(
                    child: Container(
                        height: 400,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1)],
                        ),
                        child: SingleChildScrollView(
                            child: DeliveryList()))
                ),
              ]
          ),

          SizedBox(height: 100,),
        ],
      ),
    );
  }
}



