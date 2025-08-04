
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:miogra_admin/controller/Business&sellerCon.dart';

import '../../Models/product.dart';
import '../../controller/productController.dart';



class BusinessListGrid extends StatelessWidget {
  final BusinessSellerController controller = Get.put(BusinessSellerController());

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body:SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                Obx(() => Container(
                    child:  GridView.builder(
                      shrinkWrap: true, // Prevents GridView from taking infinite height
                      physics: NeverScrollableScrollPhysics(), // Disables inner scrolling
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1, // 3-column layout
                       // crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1, // Adjust as per UI
                      ),
                      itemCount: controller.businesses.length,
                      itemBuilder: (context, index) {
                        final product = controller.businesses[index];

                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  child: Image.asset(product.imageUrl,height:
                                  MediaQuery.of(context).size.height/4,
                                    width: MediaQuery.of(context).size.width,fit: BoxFit.fill,)
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("ID: ${product.id}", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.purple[900])),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on,color: Colors.purple[900],),
                                        Text(product.location, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Text(product.name,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 20,fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding:  EdgeInsets.all(15),
                                child: Text(product.address,
                                  style: TextStyle(color: Colors.grey[500], fontSize: 15),maxLines: 2,),
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


