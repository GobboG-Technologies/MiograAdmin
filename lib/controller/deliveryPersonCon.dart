import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../Models/deliveryPerson.dart';

class DeliveryPersonController extends GetxController {
  var selectedPerson = Rxn<int>();

  List<DeliveryPerson> deliveryPersons = [
    DeliveryPerson(
        id: "SID98765432101",
        name: "Arun",
        imageUrl: "assets/images/img1.png",
        phone: "9847593955",
        address : "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167",
        email : "abhay@gmail.com",
        isAvailable: true),
    DeliveryPerson(
        id: "SID98765432102",
        name: "Raju",
        imageUrl: "assets/images/img2.png",
        isAvailable: true,
        phone: "9847593955",
        address : "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167",
        email : "abhay@gmail.com"),
    DeliveryPerson(
        id: "SID98765432103",
        name: "Raju",
        imageUrl: "assets/images/img3.png",
        phone: "9847593955",
        address : "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167",
        email : "abhay@gmail.com",
        isAvailable: false),
    DeliveryPerson(
        id: "SID98765432101",
        name: "Arun",
        phone: "9847593955",
        address : "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167",
        email : "abhay@gmail.com",
        imageUrl: "assets/images/img1.png",
        isAvailable: true),
    DeliveryPerson(
        id: "SID98765432102",
        name: "Raju",
        imageUrl: "assets/images/img2.png",
        phone: "9847593955",
        address : "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167",
        email : "abhay@gmail.com",
        isAvailable: false),
    DeliveryPerson(
        id: "SID98765432103",
        name: "Raju",
        imageUrl: "assets/images/img3.png",
        phone: "9847593955",
        address : "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167",
        email : "abhay@gmail.com",
        isAvailable: true),
    DeliveryPerson(
        id: "SID98765432102",
        name: "Raju",
        imageUrl: "assets/images/img2.png",
        phone: "9847593955",
        address : "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167",
        email : "abhay@gmail.com",
        isAvailable: true),
    DeliveryPerson(
        id: "SID98765432103",
        name: "Raju",
        imageUrl: "assets/images/img3.png",
        phone: "9847593955",
        address : "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167",
        email : "abhay@gmail.c,om",
        isAvailable: true),
  ].obs;

  void toggleLiveStatus(int index) {
    deliveryPersons[index].isAvailable.toggle();
    update();
  }
}