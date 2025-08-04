
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../Models/Banner_Model.dart';
import '../../controller/BannerController.dart';
import 'BannerUploadPage.dart';

class BannerPage extends StatelessWidget {
  final BannerController bannerController = Get.put(BannerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            /// **Upload Button**
            TextButton(
                onPressed: () => Get.dialog(BannerForm()),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.cloud_upload,color: Colors.purple[900],),
                    SizedBox(width: 5,),
                    Text("Upload Banner",style: TextStyle(color: Colors.purple[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 15),),
                  ],
                )),

            SizedBox(height: 20),

            /// **Table Container**
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey[300],
                ),
                child: Column(
                  children: [
                    /// **Table Header**
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      color: Colors.grey[300],
                      child: Row(
                        children: [
                          Expanded(child: Center(child: Text("Image", style: TextStyle(fontWeight: FontWeight.bold)))),
                          Expanded(child: Center(child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold)))),
                          Expanded(child: Center(child: Text("Duration", style: TextStyle(fontWeight: FontWeight.bold)))),
                          Expanded(child: Center(child: Text("Redirect To", style: TextStyle(fontWeight: FontWeight.bold)))),
                          Expanded(child: Center(child: Text("Action", style: TextStyle(fontWeight: FontWeight.bold)))),
                        ],
                      ),
                    ),

                    Divider(thickness: 2, color: Colors.black), // **Divider Below Header**

                    /// **Table Data**
                    Expanded(
                      child: SingleChildScrollView(
                        child: Obx(() => Column(
                          children: bannerController.banners.asMap().entries.map((entry) {
                            int index = entry.key;
                            BannerModel banner = entry.value;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5), // **Spacing Between Rows**
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.black12)), // **Row Separator**
                                ),
                                child: Row(
                                  children: [
                                    /// **Image Column (300x150)**
                                    Expanded(
                                      child: Container(
                                        width: 300,
                                        height: 150,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.black12),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: banner.imageBytes.isNotEmpty
                                            ? ClipRRect(
                                          borderRadius: BorderRadius.circular(5),
                                          child: Image.memory(
                                            banner.imageBytes,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                            : Container(
                                          color: Colors.grey,
                                          child: Icon(Icons.image_not_supported, size: 50, color: Colors.white),
                                        ),
                                      ),
                                    ),

                                    /// **Name Column**
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          banner.name,
                                          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),
                                        ),
                                      ),
                                    ),

                                    /// **Duration Column (Formatted)**
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text("${banner.startDate}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,color: Colors.black)),
                                          SizedBox(height: 4),
                                          Text("TO", style: TextStyle(fontSize: 12, color: Colors.black,)),
                                          SizedBox(height: 4),
                                          Text("${banner.endDate}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,color: Colors.black)),
                                        ],
                                      ),
                                    ),

                                    /// **Redirect To Column**
                                    Expanded(
                                      child: Center(child: Text(banner.category,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),
                                    ),

                                    /// **Actions Column**
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          /// **Toggle Active**
                                          Switch(
                                            value: banner.isActive,
                                            onChanged: (value) => bannerController.toggleBannerStatus(index),
                                            activeColor: Colors.green,
                                          ),
                                          /// **Edit Button**
                                          IconButton(
                                            icon: Icon(Icons.edit, color: Colors.red),
                                            onPressed: () => Get.dialog(
                                                BannerForm(isEdit: true, banner: banner, index: index)),
                                          ),
                                          /// **Delete Button**
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => bannerController.removeBanner(index),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
