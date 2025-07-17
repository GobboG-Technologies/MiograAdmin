import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ShopController extends GetxController {
  var selectedShopIndex = (-1).obs;

  var shops = [
    {
      "name": "Arya Bhavan ",
      "address": "TMJ complex, Thiruvithankodu,\n Azahiamandapam,\n Tamil Nadu 629167",
      "id": "SID98765432101",
      "image": "assets/images/idili.png",
      "status": Colors.green,
    },
    {
      "name": "Bismi",
      "address": "TMJ complex, Thiruvithankodu,\n Azahiamandapam,\n Tamil Nadu 629167",
      "id": "SID98765432102",
      "image": "assets/images/idili.png",
      "status": Colors.orange,
    },
    {
      "name": "Dindugal Biriyani",
      "address": "TMJ complex, Thiruvithankodu,\n Azahiamandapam,\n Tamil Nadu 629167",
      "id": "SID98765432103",
      "image": "assets/images/idili.png",
      "status": Colors.orange,
    },
    {
      "name": "Biriyani Hub",
      "address": "TMJ complex, Thiruvithankodu,\n Azahiamandapam,\n Tamil Nadu 629167",
      "id": "SID98765432104",
      "image": "assets/images/idili.png",
      "status": Colors.orange,
    },
    {
      "name": "Sharavana Bhavan",
      "address": "TMJ complex, Thiruvithankodu,\n Azahiamandapam,\n Tamil Nadu 629167",
      "id": "SID98765432105",
      "image": "assets/images/idili.png",
      "status": Colors.green,
    },
    {
      "name": "Aaryas",
      "address": "TMJ complex, Thiruvithankodu,\n Azahiamandapam,\n Tamil Nadu 629167",
      "id": "SID98765432106",
      "image": "assets/images/idili.png",
      "status": Colors.green,
    },
    {
      "name": "Aaryas",
      "address": "TMJ complex, Thiruvithankodu,\n Azahiamandapam,\n Tamil Nadu 629167",
      "id": "SID98765432107",
      "image": "assets/images/idili.png",
      "status": Colors.green,
    },
    {
      "name": "Aaryas",
      "address": "TMJ complex, Thiruvithankodu,\n Azahiamandapam,\n Tamil Nadu 629167",
      "id": "SID98765432108",
      "image": "assets/images/idili.png",
      "status": Colors.green,
    },
  ].obs;

  void selectShop(int index) {
    selectedShopIndex.value = index;
  }
}