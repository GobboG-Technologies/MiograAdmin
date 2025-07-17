

import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';

import '../Models/Banner_Model.dart';

class BannerController extends GetxController {
  var banners = <BannerModel>[
    // BannerModel(
    //   image: 'assets/images/img10.png',
    //   name: 'Chinese Food',
    //   startDate: '01-01-2025, 10:00 AM',
    //   endDate: '10-01-2025, 10:00 AM',
    //   category: 'Food',
    //   isActive: true,
    // ),
    // BannerModel(
    //   image: 'assets/images/img11.png',
    //   name: 'Italian Special',
    //   startDate: '05-01-2025, 12:00 PM',
    //   endDate: '15-01-2025, 12:00 PM',
    //   category: 'Food',
    //   isActive: false,
    // ),
  ].obs;

  var selectedImageBytes = Rxn<Uint8List>(); // Store image as bytes for Web compatibility

  // Function to pick an image
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImageBytes.value = await pickedFile.readAsBytes(); // Convert to Uint8List
    }
  }

  // Function to add a new banner
  void addBanner(String name, String startDate, String endDate, String category) {
    if (selectedImageBytes.value != null) {
      banners.add(BannerModel(
        imageBytes: selectedImageBytes.value!,
        name: name,
        startDate: startDate,
        endDate: endDate,
        category: category,
        isActive: true,

      ));
      selectedImageBytes.value = null; // Reset after adding
    }
  }

  // void addBanner(BannerModel banner) {
  //   banners.add(banner);
  // }

  void removeBanner(int index) {
    banners.removeAt(index);
  }

  void toggleBannerStatus(int index) {
    banners[index].isActive = !banners[index].isActive;
    //update();
    banners.refresh();
  }
}