
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../Models/RequestProductModel.dart';

class RequestProductController extends GetxController {
  var products = <RequestProduct>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  void fetchProducts() {
    products.assignAll([
      RequestProduct(
        id: "PID98765432101",
        name: "Idli + Sambar + Vadai + Chutney...",
        imageUrl: "assets/images/idili.png", // Change path as per your asset
        quantity: 20,
        sellerPrice: 80,
        sellingPrice: 85,
        option: true,
        isApproved: false,
        isRejected: false,
      ),
      RequestProduct(
        id: "PID98765432102",
        name: "Ghee Rice + Poached Egg + Chicken...",
        imageUrl: "assets/images/img7.png",
        quantity: 15,
        sellerPrice: 75,
        sellingPrice: 90,
        option:false ,
        isApproved: false,
        isRejected: false,
      ),
    ]);
  }


  void toggleApproval(int index) {
    if (!products[index].isRejected.value) {
      products[index].isApproved.value = !products[index].isApproved.value;
    }
  }

  void rejectProduct(int index) {
    products[index].isRejected.value = true;
    products[index].isApproved.value = false; // Ensure approval is removed
  }
}