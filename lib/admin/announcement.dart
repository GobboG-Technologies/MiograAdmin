import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnnouncementController extends GetxController {
  var selectedTab = 0.obs;

  final List<String> tabNames = ['End User', 'Business', 'Delivery'];

  var announcements = {
    'End User': <Map<String, dynamic>>[].obs,
    'Business': <Map<String, dynamic>>[].obs,
    'Delivery': <Map<String, dynamic>>[].obs,
  };



  void addAnnouncement(String tab, Uint8List? image, String text) {
    String formattedDate = DateTime.now().toLocal().toString().split(' ')[0]; // Get only YYYY-MM-DD
    announcements[tab]?.add({'image': image, 'text': text ,'date': formattedDate,});
    //update();
  }

  void removeAnnouncement(String tab, int index) {
    announcements[tab]?.removeAt(index);
  }
}



class AnnouncementPage extends StatelessWidget {
  final AnnouncementController controller = Get.put(AnnouncementController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Obx(() => Center(
              child: Container(
                width: MediaQuery.sizeOf(context).width/3,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildTabButton('End User',0, controller),
                    _buildTabButton('Business', 1,controller),
                    _buildTabButton('Delivery', 2,controller),
                  ],
                ),
              ),
            )),
            SizedBox(height: 20),
            AddAnnouncementButton(),
            SizedBox(height: 20),
            Expanded(child:  AnnouncementList()),
            SizedBox(height: 20),
            _buildCloseButton()

          ],
        ),
      ),
    );
  }

  ///  Close Button
  Widget _buildCloseButton() {
    return ElevatedButton(
      onPressed: () => Get.back(), // Close the dialog or navigate back
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.orange, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
      child: Text(
        "Close",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.orange),
      ),
    );
  }

  Widget _buildTabButton(String title, int index, AnnouncementController controller) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.selectedTab.value = index;
        },
        child: Container(
          decoration: BoxDecoration(
            color: controller.selectedTab.value == index
                ? Color(0xFF5D348B)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: controller.selectedTab.value == index
                  ? Colors.white
                  : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class AnnouncementList extends StatelessWidget {
  final AnnouncementController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      String selectedCategory = controller.tabNames[controller.selectedTab.value];
      var currentAnnouncements = controller.announcements[selectedCategory] ?? [];
      return ListView.builder(
        itemCount: currentAnnouncements.length,
        itemBuilder: (context, index) {
          var announcement = currentAnnouncements[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              leading: announcement['image'] != null && announcement['image'] is Uint8List
                  ? Image.memory(announcement['image'], width: 50, height: 50, fit: BoxFit.cover)
                  : Icon(Icons.image, size: 50, color: Colors.grey),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(announcement['text'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 6,),
                  Text(announcement['date'] ?? '',style: TextStyle(color: Colors.purple[900]),)
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => controller.removeAnnouncement(selectedCategory, index),
              ),
            ),
          );
        },
      );
    });
  }
}

class AddAnnouncementButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        child: ElevatedButton.icon(
          onPressed: () => Get.dialog(AddAnnouncementDialog()),
          icon: Icon(Icons.add, color: Colors.white),
          label: Text("Add",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),),

        ),
      ),
    );
  }
}



class AddAnnouncementDialog extends StatefulWidget {
  @override
  _AddAnnouncementDialogState createState() => _AddAnnouncementDialogState();
}

class _AddAnnouncementDialogState extends State<AddAnnouncementDialog> {
  final AnnouncementController controller = Get.find();
  final TextEditingController textController = TextEditingController();
  String imageUrl = '';
  Uint8List? imageBytes;
  String? fileName;

  @override
  Widget build(BuildContext context) {
    return  Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Colors.transparent, // Remove dialog border
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: Colors.grey[300], // Grey background
          borderRadius: BorderRadius.circular(15),
        ),

        padding: const EdgeInsets.all(20.0),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  withData: true, // Loads file as Uint8List
                );

                if (result != null && result.files.isNotEmpty) {
                  setState(() {
                    imageBytes = result.files.first.bytes;
                    fileName = result.files.first.name;
                  });
                }
                // // TODO: Implement Image Picker
                // setState(() {
                //   imageUrl = "assets/images/img1.png"; // Sample image URL
                // });
              },
              child: Container(
                width: 150,
                height:150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  //border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:imageBytes == null
                    ? Center(child: Icon(Icons.cloud_upload, size: 50, color: Colors.grey))
                    : Image.memory(imageBytes!, fit: BoxFit.contain),
                // imageUrl.isEmpty
                //     ? Center(child: Icon(Icons.cloud_upload, size: 50, color: Colors.grey))
                //     : Image.asset(imageUrl, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: textController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: "Type here...",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder( // Apply rounded border
                  borderRadius: BorderRadius.circular(15), // Adjust roundness
                  borderSide: BorderSide.none, // Remove border line
                ),
                contentPadding: EdgeInsets.all(10),

              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text("Close",style: TextStyle(color: Colors.orange),),
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Colors.orange, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (textController.text.isNotEmpty ) {
                      // You can upload the image to Firebase or store it locally
                      controller.addAnnouncement(
                          controller.tabNames[controller.selectedTab.value],  imageBytes, textController.text);
                      Get.back();
                    }
                    // if (textController.text.isNotEmpty) {
                    //   controller.addAnnouncement(controller.tabNames[controller.selectedTab.value], imageUrl, textController.text);
                    //   Get.back();
                    // }
                  },
                  child: Text("+ Add",style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[900],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), ),
                ),
              ],
            ),
          ],
        ),

      ),
    );
  }
}
