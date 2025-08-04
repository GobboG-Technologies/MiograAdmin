import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/Business&sellerCon.dart';


class SellerList extends StatelessWidget {
  final BusinessSellerController controller = Get.put(BusinessSellerController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        ListView.builder(
          shrinkWrap: true,
          itemCount: controller.sellers.length,
          itemBuilder: (context, index) {
            var seller = controller.sellers[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                height: 120, // Set a fixed height for the card
                child: Row(
                  children: [
                    // Image Container
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      child: Image.asset(
                        seller.imageUrl,
                        width: 100, // Set image width
                        height: double.infinity, // Fill full card height
                        fit: BoxFit.cover, // Ensures the image covers the area
                      ),
                    ),
                    SizedBox(width: 10),
                    // Seller Details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              seller.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 10,),
                            Text(seller.address),
                            SizedBox(height: 10,),
                            Text("ID: ${seller.id}",
                                style: TextStyle(color: Color(0xFF5D348B))),
                          ],
                        ),
                      ),
                    ),
                    // Phone Icon & Number
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, color: Color(0xFF5D348B)),
                          Text(seller.phone,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ));
  }
}
