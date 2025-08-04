import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/RequestProductModel.dart';

class RequestProductController extends GetxController {
  var products = <RequestProduct>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPausedProductsByZone();
  }

  /// Fetch products with status 'Paused' for current zone
  Future<void> fetchPausedProductsByZone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final zoneJson = prefs.getString('zoneData');
      if (zoneJson == null) return;

      final zoneData = jsonDecode(zoneJson);
      final zoneId = zoneData['zoneId'];
      if (zoneId == null || zoneId.isEmpty) return;

      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('zoneId', isEqualTo: zoneId)
          .where('productStatus', isEqualTo: 'Pending')
          .get();

      products.assignAll(productSnapshot.docs.map((doc) {
        final data = doc.data();
        return RequestProduct(
          id: doc.id,
          name: data['productName'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          quantity: int.tryParse(data['productQty'] ?? '0') ?? 0,
          sellerPrice: double.tryParse(data['yourprice'] ?? '0') ?? 0,
          sellingPrice: double.tryParse(data['productPrice'] ?? '0') ?? 0,
          option:
          (data['foodType'] ?? '').toString().toLowerCase() == 'veg' ? true : false,
          isApproved: false.obs,
          isRejected: false.obs,
        );
      }).toList());
    } catch (e) {
      print("❌ Error fetching paused products: $e");
    }
  }

  /// Approve product
  /// Approve product
  Future<void> toggleApproval(int index) async {
    final product = products[index];

    try {
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update({'productStatus': 'accepted'});

      print("✅ Product ${product.name} approved and updated in Firestore");

      // Remove from list (UI auto-updates via Obx)
      products.removeAt(index);

    } catch (e) {
      print("❌ Error approving product: $e");
    }
  }

  /// Reject product
  Future<void> rejectProduct(int index) async {
    final product = products[index];

    try {
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update({'productStatus': 'Rejected'});

      print("❌ Product ${product.name} rejected and updated in Firestore");

      // Remove from list (UI auto-updates via Obx)
      products.removeAt(index);

    } catch (e) {
      print("❌ Error rejecting product: $e");
    }
  }

}
