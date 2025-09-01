
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../controller/customer_controller.dart';
import 'customer_profileview.dart';



class CustomerCardPage extends StatelessWidget {
  final CustomerControllerpage controller = Get.put(CustomerControllerpage());

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
                Obx(() {
                  if (controller.zones.isEmpty) {
                    return const Text("No Zones Available");
                  }
                  return DropdownButton<String>(
                    value: controller.selectedZoneId.value,
                    hint: const Text("Select Zone"),
                    items: controller.zones.map((zone) {
                      return DropdownMenuItem<String>(
                        value: zone['zoneId'] as String,
                        child: Text(zone['zoneName'] as String),
                      );
                    }).toList(),
                      onChanged: (newValue) {
                        controller.onZoneChanged(newValue);
                      }
                  );
                }),
                Center(child: _buildSearchBar(controller)),
                SizedBox(height: 50),

                Obx(() => Container(
                    child:  GridView.builder(
                      shrinkWrap: true, // Prevents GridView from taking infinite height
                      physics: NeverScrollableScrollPhysics(), // Disables inner scrolling
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 3-column layout
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.6, // Adjust as per UI
                      ),
                      itemCount: controller.filteredCustomers.length,

                      itemBuilder: (context, index) {
                        final Customer = controller.filteredCustomers[index];


                        return
                          GestureDetector(
                            onTap: () {
                          // Navigate to CustomerOrdersPage with selected customer
                          Get.to(() => CustomerOrdersPage(customer: Customer));
                        },
                        child:
                        Card(
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
                                        child:GestureDetector(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.all(Radius.circular(12)),
                                            child: Image.asset(
                                              'assets/images/img1.png', // your image path
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),

                                      ),
                                    ),
                                    SizedBox(width: 20,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(Customer.name, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey,fontSize: 20)),
                                        SizedBox(height: 15,),
                                        Text(Customer.phone, style: TextStyle(color: Colors.grey,fontSize: 20,fontWeight: FontWeight.bold)),
                                        SizedBox(height: 15,),
                                        Text(Customer.email, style: TextStyle(color: Colors.black,fontSize: 15)),

                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ));
                      },
                    )),
                ),
              ],
            ),
          )),
    );
  }
  // Search Bar
  Widget _buildSearchBar(CustomerControllerpage controller) {
    return Container(
      width: 600,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        onChanged: (value) => controller.searchText.value = value,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          hintText: "Search by Name or Order ID",
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
        ),
      ),
    );
  }
}
