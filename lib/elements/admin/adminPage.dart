
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:miogra_admin/controller/adminController.dart';
import '../../controller/customer_controller.dart';
import '../../example.dart';
import 'adminViewProfile.dart';


class AdminCardPage extends StatelessWidget {
  final AdminControllerpage controller = Get.put(AdminControllerpage());

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
                Center(child: _buildSearchBar()),
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
                      itemCount: controller.admin.length,
                      itemBuilder: (context, index) {
                        final Admin = controller.admin[index];

                        return
                          GestureDetector(
                              onTap: () {
                                Get.to(() => AdminProfilePreviewPage(admin: Admin)); // Navigate to ProfilePreviewPage with admin details
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
                                              child: Image.asset(Admin.image as String,
                                                  height: 200, width: 100, fit: BoxFit.fill),
                                            ),
                                          ),
                                          SizedBox(width: 20,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(Admin.name, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey,fontSize: 20)),
                                              SizedBox(height: 15,),
                                              Text(Admin.phone, style: TextStyle(color: Colors.grey,fontSize: 20,fontWeight: FontWeight.bold)),
                                              SizedBox(height: 15,),
                                              Text(Admin.email, style: TextStyle(color: Colors.black,fontSize: 15)),
                                              SizedBox(height: 15,),
                                              Row(
                                                children: [
                                                  Icon(Icons.location_on,color: Colors.purple[900],),
                                                  Text(Admin.location, style: TextStyle(color: Colors.purple[900],fontSize: 15,)),
                                                ],
                                              ),
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



