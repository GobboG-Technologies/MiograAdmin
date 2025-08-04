import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/orderController.dart';
import '../elements/Order/liveOrders.dart';
import '../elements/Order/orderReqPage.dart';
import '../elements/Order/orderappbar.dart';
import '../elements/Order/togglebutton.dart';
import '../elements/Seller/seller_page.dart';
import '../example.dart';

class SellerPage extends StatelessWidget {
  final OrderController controller = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //appbar
            OrderTopBar(),
            const SizedBox(height: 20),
            // Search Bar
            Center(child: _buildSearchBar()),
            const SizedBox(height: 20),
            // Content Based on Selection
            Expanded(
              child:  SellerCard(),
            ),
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
