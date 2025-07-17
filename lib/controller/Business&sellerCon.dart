import 'package:get/get.dart';

import '../Models/BusinessList.dart';
import '../Models/sellerList.dart';

class BusinessSellerController extends GetxController {
  var businesses = <Business>[].obs;
  var sellers = <Seller>[].obs;
  var selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() {
    businesses.addAll([
      Business(
        name: "Arya Bhavan",
        address: "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167",
        id: "SID98765432101",
        location: "Nagercoil",
        imageUrl: "assets/images/img9.png",
        isLive: true,
        isApproved: false,
        isRejected: false,
      ),
      Business(
        name: "Arya Bhavan",
        address: "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167",
        id: "SID98765432101",
        location: "Thuckalay",
        imageUrl: "assets/images/img9.png",
          isLive: true,
        isApproved: false,
        isRejected: false,
      ),
      Business(
        name: "Arya Bhavan",
        address: "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167",
        id: "SID98765432101",
        location: "Thuckalay",
        imageUrl: "assets/images/img9.png",
          isLive: true,
        isApproved: false,
        isRejected: false,
      ),
      Business(
        name: "Arya Bhavan",
        address: "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167",
        id: "SID98765432101",
        location: "Thuckalay",
        imageUrl: "assets/images/img9.png",
          isLive: false,
        isApproved: false,
        isRejected: false,
      ),
    ]);

    sellers.addAll([
      Seller(
        name: "Mahendran",
        address: "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167",
        id: "SID98765432101",
        phone: "9876543210",
        imageUrl: "assets/images/img1.png",
      ),
      Seller(
        name: "Abilash",
        address: "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167",
        id: "SID98765432101",
        phone: "9876543210",
        imageUrl: "assets/images/img3.png",
      ),
      Seller(
        name: "Mahendran",
        address: "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167",
        id: "SID98765432101",
        phone: "9876543210",
        imageUrl: "assets/images/img1.png",
      ),
      Seller(
        name: "Abilash",
        address: "TMJ complex, Thiruvithankodu, Azhaiamandapam, Tamil Nadu 629167",
        id: "SID98765432101",
        phone: "9876543210",
        imageUrl: "assets/images/img3.png",
      ),
    ]);
  }
  void toggleApproval(int index) {
    if (!businesses[index].isRejected.value) {
      businesses[index].isApproved.value = !businesses[index].isApproved.value;
    }
  }

  void rejectProduct(int index) {
    businesses[index].isRejected.value = true;
    businesses[index].isApproved.value = false; // Ensure approval is removed
  }
}
