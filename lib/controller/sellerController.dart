import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../Models/SellerModel.dart';

class SellerController extends GetxController {
  var sellers = <Sellers>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSellersFromFirestore();
  }

  void fetchSellersFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      final sellerList = snapshot.docs
          .map((doc) => Sellers.fromMap(doc.data(), doc.id))
          .toList();
      sellers.assignAll(sellerList);
    } catch (e) {
      print("Error fetching sellers: $e");
    }
  }

  void toggleLiveStatus(int index) {
    sellers[index].isLive.value = !sellers[index].isLive.value;
    sellers.refresh();
  }
}
