import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/product&deliverypersonCon.dart';


class DeliveryList extends StatelessWidget {
  final ProductDeliveryController controller = Get.put(ProductDeliveryController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        ListView.builder(
          shrinkWrap: true,
          itemCount: controller.delivery.length,
          itemBuilder: (context, index) {
            var delivery = controller.delivery[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                height: 125, // Set a fixed height for the card
                child: Row(
                  children: [
                    // Image Container
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      child: Image.asset(
                        delivery.imageUrl,
                        width: 100, // Set image width
                        height: double.infinity, // Fill full card height
                        fit: BoxFit.cover, // Ensures the image covers the area
                      ),
                    ),

                    SizedBox(width: 10),
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
                                  delivery.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Spacer(),
                                Icon(Icons.location_disabled_sharp,color: Color(0xFF5D348B)),
                                SizedBox(width: 5,),
                                Text(delivery.location,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),),
                              ],
                            ),

                            SizedBox(height: 10,),
                          SizedBox(
                              width: 300,
                                 child: Text(
                                    delivery.address,
                                     maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                             ),
                          ),

                            SizedBox(height: 5,),

                            Row(
                              children: [
                                Text("ID: ${delivery.id}",
                                    style: TextStyle(color: Color(0xFF5D348B))),
                                Spacer(),
                                Icon(Icons.phone, color: Color(0xFF5D348B)),
                                SizedBox(width: 5,),
                                Text(delivery.phone,
                                    style: TextStyle(fontWeight: FontWeight.bold)),
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
}
