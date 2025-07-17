import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/Business&sellerCon.dart';
import '../../controller/product&deliverypersonCon.dart';


class ProductList extends StatelessWidget {
  final ProductDeliveryController controller = Get.put(ProductDeliveryController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        ListView.builder(
          shrinkWrap: true,
          itemCount: controller.product.length,
          itemBuilder: (context, index) {
            var products = controller.product[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                height: 120,
                color: Colors.white,// Set a fixed height for the card
                child: Row(
                  children: [
                    // Image Container
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      child: Image.asset(
                        products.imageUrl,
                        width: 100, // Set image width
                        height: double.infinity, // Fill full card height
                        fit: BoxFit.contain, // Ensures the image covers the area
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
                            Row(
                              children: [
                                Text(
                                  products.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16,color: Colors.grey),
                                ),
                                Spacer(),
                                Icon(Icons.currency_rupee_sharp,color: Colors.black,),
                                Text(products.price,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                _getVegOrNonVeg(products.option),
                                SizedBox(width: 5),
                                Text(products.address),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                Text("ID: ${products.id}",
                                    style: TextStyle(color:Color(0xFF5D348B))),
                                Spacer(),
                                Icon(Icons.location_pin,color: Colors.purple[900],),
                                Text(products.location,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),),
                              ],
                            ),
                          ],
                        ),
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
  Widget _getVegOrNonVeg(String method) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: method == "veg" ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            method == "veg" ? Icons.eco : Icons.local_fire_department,
            color: method == "veg" ? Colors.green : Colors.red,
            size: 16,
          ),
          // SizedBox(width: 4),
          // Text(
          //   method,
          //   style: TextStyle(
          //     fontSize: 12,
          //     fontWeight: FontWeight.bold,
          //     color: method == "veg" ? Colors.green : Colors.red,
          //   ),
          // ),
        ],
      ),
    );
  }

}
