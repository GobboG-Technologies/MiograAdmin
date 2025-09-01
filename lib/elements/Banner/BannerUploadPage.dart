//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
//
// import '../../Models/Banner_Model.dart';
// import '../../controller/BannerController.dart';
//
// class BannerForm extends StatelessWidget {
//   final bool isEdit;
//   final BannerModel? banner;
//   final int? index;
//   final BannerController bannerController = Get.find();
//
//   BannerForm({this.isEdit = false, this.banner, this.index});
//
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController startDateController = TextEditingController();
//   final TextEditingController endDateController = TextEditingController();
//   final TextEditingController categoryController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//
//     if (isEdit && banner != null) {
//       nameController.text = banner!.name;
//       startDateController.text = banner!.startDate;
//       endDateController.text = banner!.endDate;
//       categoryController.text = banner!.category;
//       bannerController.selectedImageBytes.value = banner!.imageBytes;
//     } else {
//       bannerController.selectedImageBytes.value = null;
//     }
//
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               /// **Title with Close Button**
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("Add Banner", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                   IconButton(
//                     icon: Icon(Icons.close),
//                     onPressed: () => Get.back(),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//
//               /// **Image Upload Section**
//               Text("Upload banner image"),
//               SizedBox(height: 5),
//               GestureDetector(
//                 onTap: () async {
//                   await bannerController.pickImage();
//                 },
//                 child: Obx(() => Container(
//                   height: 150,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                   child: bannerController.selectedImageBytes.value != null
//                       ? ClipRRect(
//                     borderRadius: BorderRadius.circular(5),
//                     child: Image.memory(bannerController.selectedImageBytes.value!, fit: BoxFit.cover),
//                   )
//                       : Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
//                       SizedBox(height: 5),
//                       Text("Drag and drop a file here or click", style: TextStyle(color: Colors.grey)),
//                     ],
//                   ),
//                 )),
//               ),
//               SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Text("Logo size 1920 x 550",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
//                 ],
//               ),
//
//               SizedBox(height: 20),
//
//               /// **Name Field + Image Size**
//               //
//               //     Expanded(
//               //       child:
//               Container(
//                 width: MediaQuery.of(context).size.width/3,
//                 child: TextField(
//                   controller: nameController,
//                   decoration: InputDecoration(labelText: "Name",
//                       labelStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
//                       border: OutlineInputBorder()),
//                 ),
//               ),
//               // ),
//
//               //Text("Logo size 1920 x 550", style: TextStyle(color: Colors.grey)),
//
//               SizedBox(height: 10),
//
//               /// **Start Date & End Date Fields**
//               Row(
//                 // spacing: 10,
//                 // runSpacing: 10,
//                 children: [
//                   SizedBox(
//                     width: screenWidth > 600 ? (screenWidth / 3) - 30 : double.infinity,
//                     child: TextField(
//                       controller: startDateController,
//                       decoration: InputDecoration(labelText: "Start Date",
//                           labelStyle: TextStyle(fontWeight: FontWeight.bold,
//                               color: Colors.black),
//                           border: OutlineInputBorder()),
//                     ),
//                   ),
//                   SizedBox(width: 15,),
//                   SizedBox(
//                     width: screenWidth > 600 ? (screenWidth / 3) - 30 : double.infinity,
//                     child: TextField(
//                       controller: endDateController,
//                       decoration: InputDecoration(labelText: "End Date",
//                           border: OutlineInputBorder(),
//                           labelStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 20),
//
//               /// **Assign To Dropdown**
//               Text("Assign To",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
//               SizedBox(height: 5),
//
//               Container(
//                 width: MediaQuery.of(context).size.width/3,
//                 child: DropdownButtonFormField<String>(
//                   decoration: InputDecoration(border: OutlineInputBorder()),
//                   value: null,
//                   items: ["Category 1", "Category 2", "Category 3"]
//                       .map((item) => DropdownMenuItem(value: item, child: Text(item)))
//                       .toList(),
//                   onChanged: (value) {
//                     categoryController.text = value!;
//                   },
//                   hint: Text("Select",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
//                 ),
//               ),
//               SizedBox(height: 20),
//
//               /// **Add/Update Button**
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (isEdit) {
//                       bannerController.banners[index!] = BannerModel(
//                         imageBytes: bannerController.selectedImageBytes.value ?? banner!.imageBytes,
//                         name: nameController.text,
//                         startDate: startDateController.text,
//                         endDate: endDateController.text,
//                         category: categoryController.text,
//                         isActive: banner!.isActive,
//                       );
//                     } else {
//                       if (bannerController.selectedImageBytes.value != null) {
//                         bannerController.addBanner(
//                           nameController.text,
//                           startDateController.text,
//                           endDateController.text,
//                           categoryController.text,
//                         );
//                       } else {
//                         Get.snackbar("Error", "Please select an image");
//                       }
//                     }
//                     bannerController.banners.refresh();
//                     Get.back();
//                   },
//                   child: Text(isEdit ? "Update" : "Add",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }