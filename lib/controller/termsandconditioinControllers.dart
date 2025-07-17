
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class UserFormController extends GetxController {
  var selectedTab = 0.obs;

  // Store terms separately for each tab
  var terms = {
    0: ''.obs, // End User
    1: ''.obs, // Business
    2: ''.obs, // Delivery
  };

  var titleTexts = ["", "", ""].obs;
  var descriptionTexts = ["", "", ""].obs;

  late List<TextEditingController> titleControllers;
  late List<TextEditingController> descriptionControllers;

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers with respective saved values
    titleControllers = List.generate(3, (index) => TextEditingController(text: titleTexts[index]));
    descriptionControllers = List.generate(3, (index) => TextEditingController(text: descriptionTexts[index]));
  }

  void updateTitle(String text) {
    titleTexts[selectedTab.value] = text;
  }

  void updateDescription(String text) {
    descriptionTexts[selectedTab.value] = text;
  }



}