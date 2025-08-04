
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:miogra_admin/Models/SellerModel.dart';
import 'package:miogra_admin/Models/sellerList.dart';
import 'package:miogra_admin/elements/Seller/sellerBusinessList.dart';
import 'package:miogra_admin/elements/Seller/seller_Edit.dart';

import '../../Models/product.dart';
import '../../controller/deliveryPersonCon.dart';
import '../../controller/productController.dart';
import '../../controller/sellerController.dart';
import '../Business/business_dropdown.dart';


class DeliveryCardPage extends StatelessWidget {
  final DeliveryPersonController controller = Get.put(DeliveryPersonController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    FilterWidget(),
                    Spacer(),
                    TextButton(
                      onPressed: () {  },
                      child: Text( "+ Add Delivery",
                        style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold), ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Obx(() => Container(
                    child:  GridView.builder(
                      shrinkWrap: true, // Prevents GridView from taking infinite height
                      physics: NeverScrollableScrollPhysics(), // Disables inner scrolling
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 3-column layout
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1, // Adjust as per UI
                      ),
                      itemCount: controller.deliveryPersons.length,
                      itemBuilder: (context, index) {
                        final deliveryPerson = controller.deliveryPersons[index];

                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all( Radius.circular(12),),
                                        child: Image.asset(deliveryPerson.imageUrl as String,
                                            height: 200, width: 100, fit: BoxFit.fill),
                                      ),
                                    ),
                                    SizedBox(width: 20,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(deliveryPerson.name, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey,fontSize: 20)),
                                        SizedBox(height: 15,),
                                        Text("ID: ${deliveryPerson.id}",
                                            style: TextStyle(color: Colors.purple[900], fontSize: 15,fontWeight: FontWeight.bold)),
                                        SizedBox(height: 15,),
                                        Text(deliveryPerson.phone, style: TextStyle(color: Colors.grey,fontSize: 20,fontWeight: FontWeight.bold)),
                                        SizedBox(height: 15,),
                                        Text(deliveryPerson.email, style: TextStyle(color: Colors.black,fontSize: 15)),
                                        SizedBox(height: 15,),
                                        Row(
                                          children: [
                                            Icon(Icons.circle, color: deliveryPerson.isAvailable.value ? Colors.green : Colors.red, size: 12),
                                            SizedBox(width: 4),
                                            Text( deliveryPerson.isAvailable.value ? "Live" : "Offline",
                                                style: TextStyle(color: deliveryPerson.isAvailable.value ? Colors.green : Colors.red,fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Text(deliveryPerson.address, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey,fontSize: 17)),
                              ),

                              Expanded(child: Container()),
                              Container(
                                decoration:  BoxDecoration(color: Colors.purple[900],
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                                ),
                                width: MediaQuery.sizeOf(context).width,
                                height:50,
                                child: TextButton.icon(
                                  onPressed: () {
                                   // Get.to(() => SellerProfileEditPage());
                                  },
                                  icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                                  label: const Text("Edit", style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )),
                ),
              ],
            ),
          )),
    );
  }
}



