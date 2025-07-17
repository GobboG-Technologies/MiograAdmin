import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miogra_admin/Models/SellerModel.dart';
import 'package:miogra_admin/elements/Seller/sellerBusinessList.dart';
import 'package:miogra_admin/elements/Seller/seller_Edit.dart';

import '../../controller/sellerController.dart';

class SellerCard extends StatelessWidget {
  final SellerController controller = Get.put(SellerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => SellerProfileEditPage()); // No sellerId → add mode
                  },
                  child: Text(
                    "+ Add Seller",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 30),
                Obx(() => Container(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: controller.sellers.length,
                    itemBuilder: (context, index) {
                      final seller = controller.sellers[index];

                      return Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        showSellerPopup(context, seller, index, controller),
                                    child: ClipRRect(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                      child: seller.imageUrl.isNotEmpty
                                          ? Image.network(
                                        seller.imageUrl,
                                        height: 200,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      )
                                          : Image.asset(
                                        'assets/images/img5.png',
                                        height: 200,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(seller.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              fontSize: 20)),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text("ID: ${seller.id}",
                                          style: TextStyle(
                                              color: Colors.purple[900],
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(seller.phone,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(seller.email,
                                          style: TextStyle(
                                              color: Colors.black, fontSize: 15)),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            color: controller
                                                .sellers[index].isLive.value
                                                ? Colors.green
                                                : Colors.red,
                                            size: 12,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            controller.sellers[index].isLive.value
                                                ? "Live"
                                                : "Offline",
                                            style: TextStyle(
                                                color: controller
                                                    .sellers[index].isLive.value
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(seller.address,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      fontSize: 17)),
                            ),
                            Expanded(child: Container()),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.purple[900],
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(12),
                                ),
                              ),
                              width: MediaQuery.sizeOf(context).width,
                              height: 50,
                              child: TextButton.icon(
                                onPressed: () {
                                  Get.to(() => SellerProfileEditPage(sellerId: seller.id)); // 👈 Pass the seller ID here
                                },
                                icon: Icon(Icons.edit, color: Colors.white, size: 16),
                                label: Text("Edit", style: TextStyle(color: Colors.white)),
                              ),
                            ),

                          ],
                        ),
                      );
                    },
                  ),
                )),
              ],
            ),
          )),
    );
  }
}

void showSellerPopup(
    BuildContext context, Sellers seller, int index, SellerController controller) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width / 3,
        constraints:
        BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: seller.imageUrl.isNotEmpty
                        ? NetworkImage(seller.imageUrl)
                        : AssetImage('assets/images/img5.png') as ImageProvider,
                  ),
                ),
                SizedBox(height: 20),

                // Name & ID
                Row(
                  children: [
                    Text(
                      seller.name,
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Text(
                      "ID:${seller.id}",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[900]),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Phone Number
                Text(
                  "+91 ${seller.phone}",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                SizedBox(height: 10),

                // Email
                Text(
                  seller.email,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 8),
                SizedBox(height: 16),

                // Live Toggle & Close Button
                Obx(() => Row(
                  children: [
                    GestureDetector(
                      onTap: () => controller.toggleLiveStatus(index),
                      child: Container(
                        width: 50,
                        height: 20,
                        decoration: BoxDecoration(
                          color: controller.sellers[index].isLive.value
                              ? Colors.green[200]
                              : Colors.red[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: controller.sellers[index].isLive.value
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                width: 20,
                                height: 20,
                                margin: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: controller.sellers[index].isLive.value
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 2),
                    Text(
                      controller.sellers[index].isLive.value ? "Live" : "Offline",
                      style: TextStyle(
                        color: controller.sellers[index].isLive.value
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),

                    // Close Button
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.orange, width: 2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                      ),
                      child: Text(
                        "Close",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange),
                      ),
                    )
                  ],
                )),
                SizedBox(height: 20),

                // Business List Grid - Assuming you have this widget
                SizedBox(
                  height: 800,
                  child: BusinessListGrid(),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
