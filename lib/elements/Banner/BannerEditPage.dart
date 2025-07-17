import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class BannerEController extends GetxController {
  var selectedImageBytes = Rxn<Uint8List>(); // Holds image data
  var selectedCategory = "".obs; // Holds selected category

  // Pick an image from the gallery
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      selectedImageBytes.value = await image.readAsBytes();
    }
  }
}


class BannerUploadPage extends StatelessWidget {
  final BannerEController controller = Get.put(BannerEController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 350,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// **Image Upload Section**
              Obx(() => Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: controller.selectedImageBytes.value != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        controller.selectedImageBytes.value!,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Icon(Icons.image_outlined, size: 80, color: Colors.grey[400]),
                  ),

                  /// **Upload Button**
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: controller.pickImage,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 18,
                        child: Icon(Icons.upload_rounded, color: Colors.purple[900], size: 20),
                      ),
                    ),
                  ),
                ],
              )),
              SizedBox(height: 16),

              /// **Category Dropdown**
              Obx(() => DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                value: controller.selectedCategory.value.isEmpty ? null : controller.selectedCategory.value,
                items: ["Category 1", "Category 2", "Category 3"]
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) {
                  controller.selectedCategory.value = value!;
                },
                hint: Text("Category"),
              )),
              SizedBox(height: 16),

              /// **Close & Save Buttons**
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text("Close", style: TextStyle(color: Colors.orange)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.selectedImageBytes.value == null || controller.selectedCategory.value.isEmpty) {
                        Get.snackbar("Error", "Please select an image and a category");
                        return;
                      }
                      // Save banner logic
                      Get.snackbar("Success", "Banner saved successfully");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[900],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text("Save", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
