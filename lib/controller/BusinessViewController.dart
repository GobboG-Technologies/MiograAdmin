import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class BusinessViewController extends GetxController {
  final String shopId;
  BusinessViewController({required this.shopId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable variables for the UI to listen to
  var isLoading = true.obs;
  var shopData = Rx<Map<String, dynamic>?>(null);
  var productList = Rx<List<QueryDocumentSnapshot>>([]);
  var error = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Fetch both shop and product data when the controller is initialized
    fetchShopAndProductData();
  }

  Future<void> fetchShopAndProductData() async {
    try {
      isLoading.value = true;
      error.value = null;

      // Perform both Firestore queries concurrently for better performance
      final results = await Future.wait([
        // Future 1: Get Shop Details
        _firestore.collection('Shops').doc(shopId).get(),

        // Future 2: Get Products for that Shop
        _firestore.collection('products').where('shopId', isEqualTo: shopId).get(),
      ]);

      // Process the result for shop details
      final shopDoc = results[0] as DocumentSnapshot;
      if (shopDoc.exists) {
        shopData.value = shopDoc.data() as Map<String, dynamic>;
      } else {
        throw 'Shop with ID $shopId not found.';
      }

      // Process the result for products
      final productQuery = results[1] as QuerySnapshot;
      productList.value = productQuery.docs;

    } catch (e) {
      print("Error fetching business view data: $e");
      error.value = "Failed to load data: $e";
    } finally {
      isLoading.value = false;
    }
  }
}