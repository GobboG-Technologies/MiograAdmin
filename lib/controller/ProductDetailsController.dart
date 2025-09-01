import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailsController extends GetxController {
  final String productName;

  ProductDetailsController(this.productName);

  var productData = <String, dynamic>{}.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    try {
      isLoading.value = true;

      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('productName', isEqualTo: productName)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        productData.value = snapshot.docs.first.data();
      } else {
        Get.snackbar("Not Found", "No product found with name $productName");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch product: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
