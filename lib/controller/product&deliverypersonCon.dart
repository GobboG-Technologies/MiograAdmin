import 'package:get/get.dart';

import '../Models/BusinessList.dart';
import '../Models/deliveryList.dart';
import '../Models/productsList.dart';
import '../Models/sellerList.dart';

class ProductDeliveryController extends GetxController {
  var product = <Products>[].obs;
  var delivery = <Delivery>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() {
    product.addAll([
      Products(
        name: "Chicken Biriyani",
        address: "Biriyani Center",
        id: "SID98765432101",
        location: "Nagercoil",
        imageUrl: "assets/images/img7.png",
        option: "non-veg",
        price: "220"
      ),
      Products(
        name: "Mutton Biriyani",
        address: "Amboor Biriyani",
        id: "SID98765432101",
        location: "Thuckalay",
        imageUrl: "assets/images/img8.png",
          option: "non-veg",
          price: "320"
      ),
      Products(
        name: "Beef Biriyani",
        address: "Biriyani Majlis",
        id: "SID98765432101",
        location: "Thuckalay",
        imageUrl: "assets/images/img7.png",
          option: "non-veg",
          price: "300"
      ),
      Products(
        name: "Veg Biriyani",
        address: "Biriyani Center",
        id: "SID98765432101",
        location: "Thuckalay",
        imageUrl: "assets/images/img8.png",
          option: "veg",
          price: "180"
      ),
    ]);

    delivery.addAll([
      Delivery(
        name: "Mahendran",
        address: "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167552552",
        id: "SID98765432101",
        phone: "9876543210",
        imageUrl: "assets/images/img5.png",
        location: "Nagercoil"
      ),
      Delivery(
        name: "Abilash",
        address: "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167",
        id: "SID98765432101",
        phone: "9876543210",
        imageUrl: "assets/images/img6.png",
          location: "Madurai"
      ),
      Delivery(
        name: "Mahendran",
        address: "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167",
        id: "SID98765432101",
        phone: "9876543210",
        imageUrl: "assets/images/img5.png",
          location: "Nagercoil"
      ),
      Delivery(
        name: "Abilash",
        address: "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167",
        id: "SID98765432101",
        phone: "9876543210",
        imageUrl: "assets/images/img6.png",
          location: "Nagercoil"
      ),
    ]);
  }
}
