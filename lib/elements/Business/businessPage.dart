
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:miogra_admin/controller/Business&sellerCon.dart';

import '../../Models/product.dart';
import '../../controller/productController.dart';
import 'business_dropdown.dart';


class BusinessGrid extends StatelessWidget {
  final BusinessSellerController controller = Get.put(BusinessSellerController());
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

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
                // Search Bar
                Center(child: _buildSearchBar()),
                 SizedBox(height: 50),

                Row(
                  children: [
                    FilterWidget(),
                    Spacer(),
                    // Text(
                    //   "+ Add Business",
                    //   style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),
                    // ),
                  ],
                ),
                SizedBox(height: 30),
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
                      itemCount: controller.businesses.length,
                      itemBuilder: (context, index) {
                        final product = controller.businesses[index];

                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                child: Image.asset(product.imageUrl,height:
                                  MediaQuery.of(context).size.height/4,
                                  width: MediaQuery.of(context).size.width,fit: BoxFit.fill,)
                              ),
                             Padding(
                               padding: const EdgeInsets.fromLTRB(15,5,5,15),
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
                                      padding: const EdgeInsets.fromLTRB(15,0,15,0),
                                      child: Row(
                                            children: [
                                              Text(product.name,
                                                  style: TextStyle(color: Colors.grey[600], fontSize: 15,fontWeight: FontWeight.bold)),
                                              //SizedBox(width: MediaQuery.of(context).size.width/10,),
                                              Spacer(),
                                              Icon(Icons.circle, color:  controller.businesses[index].isLive.value ? Colors.green : Colors.red, size: 12),
                                              SizedBox(width: 4),
                                              Text( controller.businesses[index].isLive.value ? "Live" : "Offline",
                                                  style: TextStyle(color: controller.businesses[index].isLive.value ? Colors.green : Colors.red,fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                    ),

                               Padding(
                                 padding:  EdgeInsets.all(15),
                                 child: Text(product.address,
                                    style: TextStyle(color: Colors.grey[500], fontSize: 15),maxLines: 2,),
                               ),

                             Text(formattedDate,style: TextStyle(color: Colors.purple[900]),),


                              Expanded(child: Container()),
                              Container(
                                decoration:  BoxDecoration(color: Colors.purple[900],
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                                ),
                                width: MediaQuery.sizeOf(context).width,
                                height:50,
                                child: TextButton.icon(
                                  onPressed: () {},
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
          hintText: "Search By Product ID",
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
        ),
      ),
    );
  }
}


void showProductPopup(BuildContext context, Product product, int index, ProductController controller) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width/4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(product.imageUrl,height: 230, width: MediaQuery.of(context).size.width, fit: BoxFit.contain),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.restaurant_menu, color: product.option ? Colors.green : Colors.red, size: 30),
                  const Spacer(),
                  Text("ID: ${product.id}", style: TextStyle(color: Colors.purple[900])),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                product.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Experience the authentic taste of South India with our delicious Idli, Vadai, Saambar, and Chutney combo. Perfect for breakfast, lunch, or dinner.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Obx(() => Row(
                children: [
                  GestureDetector(
                    onTap: () => controller.toggleLiveStatus(index), // Toggle function
                    child: Container(
                      width: 50, // Width of the switch
                      height: 20, // Height of the switch
                      decoration: BoxDecoration(
                        color: controller.products[index].isLive? Colors.green[200] : Colors.red[200], // Background color changes based on status
                        borderRadius: BorderRadius.circular(6), // Slight rounded corners
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: controller.products[index].isLive? Alignment.centerRight : Alignment.centerLeft,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300), // Smooth animation
                              width: 20, // Width of the moving toggle
                              height: 20, // Height of the moving toggle
                              margin: EdgeInsets.all(1), // Space inside the switch
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:controller.products[index].isLive? Colors.green : Colors.red, // Toggle button color
                                //borderRadius: BorderRadius.circular(5), // Slight rounded corners
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 2),
                  Text(
                    controller.products[index].isLive ? "Live" : "Offline",
                    style: TextStyle(
                      color: controller.products[index].isLive? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),


                  // Switch(
                  //   value: controller.products[index].isLive.value, // Live status
                  //   onChanged: (value) => controller.toggleLiveStatus(index), // Toggle function
                  //   activeColor: Colors.green,
                  //   inactiveThumbColor: Colors.red,
                  //   inactiveTrackColor: Colors.red.shade200,
                  // ),
                  // SizedBox(width: 2),
                  // Text(
                  //   controller.products[index].isLive.value ? "Live" : "Off",
                  //   style: TextStyle(
                  //     color: controller.products[index].isLive.value ? Colors.green : Colors.red,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),


                  Spacer(),

                  ElevatedButton(
                    onPressed: () => Get.back(), // Close the dialog or navigate back
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.orange, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: Text(
                      "Close",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.orange),
                    ),
                  )
                ],
              )),
            ],
          ),
        ),
      ),
    ),
  );
}