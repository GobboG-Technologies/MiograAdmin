import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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

          // 🔹 --- Row for Dropdowns ---
          Row(
            children: [
              // Zone Dropdown
              Expanded(
                child: Obx(() => DropdownButton<String>(
                  value: controller.selectedZoneId.value,
                  isExpanded: true,
                  hint: const Text("Select Zone"),
                  items: controller.zones
                      .map((zone) => DropdownMenuItem<String>(
                    value: zone["zoneId"],
                    child: Text(zone["zoneName"] ?? "Unnamed Zone"),
                  ))
                      .toList(),
                  onChanged: (value) {
                    controller.onZoneChanged(value);
                  },
                )),
              ),
              SizedBox(width: 20.w),

              // Category Dropdown
              Expanded(
                child: Obx(() => DropdownButton<String>(
                  value: controller.selectedCategory.value,
                  isExpanded: true,
                  hint: const Text("Select Category"),
                  items: controller.categories
                      .map((category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  ))
                      .toList(),
                  onChanged: (value) {
                    controller.onCategoryChanged(value);
                  },
                )),
              ),
            ],
          ),

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
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 30,
                  childAspectRatio: 5.5,
                ),
                itemCount: ordersController.orders.length,
                itemBuilder: (context, index) {
                  var order = ordersController.orders[index];
                  return OrderCard(
                    orderId: order["orderId"] as String,
                    amount: order["amount"] as String,
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
              Expanded(child: Text("Recently Added Business", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              Expanded(child: Text("Recently Joined Sellers", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            ],
          ),
          SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  height: 400,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1)],
                  ),
                  child: SingleChildScrollView(child: BusinessList()),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 400,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1)],
                  ),
                  child: Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.recentSellers.length,
                    itemBuilder: (context, index) {
                      var seller = controller.recentSellers[index];
                      return ListTile(
                        leading: CircleAvatar(backgroundImage: NetworkImage(seller["imageUrl"] ?? "")),
                        title: Text(seller["name"] ?? ""),
                        subtitle: Text(seller["email"] ?? ""),
                        trailing: Text(seller["phone"] ?? ""),
                      );
                    },
                  )),
                ),
              ),
            ],
          ),

          SizedBox(height: 80,),

          Row(
            children: [
              Expanded(child: Text("Recently Added Products", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              Expanded(child: Text("Recently Joined Delivery Person", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            ],
          ),
          SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  height: 400,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1)],
                  ),
                  child: Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.recentProducts.length,
                    itemBuilder: (context, index) {
                      var product = controller.recentProducts[index];
                      return ListTile(
                        leading: CircleAvatar(backgroundImage: NetworkImage(product["imageUrl"] ?? "")),
                        title: Text(product["productName"] ?? ""),
                        subtitle: Text(product["shopName"] ?? ""),
                        trailing: Text("₹${product["price"] ?? ""}"),
                      );
                    },
                  )),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 400,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1)],
                  ),
                  child: Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.recentDeliveryPersons.length,
                    itemBuilder: (context, index) {
                      var dp = controller.recentDeliveryPersons[index];
                      return ListTile(
                        leading: CircleAvatar(backgroundImage: NetworkImage(dp["profile_image"] ?? "")),
                        title: Text(dp["name"] ?? ""),
                        subtitle: Text(dp["email"] ?? ""),
                        trailing: Text(dp["phone"] ?? ""),
                      );
                    },
                  )),
                ),
              ),
            ],
          ),

          SizedBox(height: 100,),
        ],
      ),
    );
  }
}
