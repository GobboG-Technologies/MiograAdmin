import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  // Your existing variables
  var selectedTab = 0.obs;
  var orders = <Map<String, dynamic>>[].obs;
  var assignedOrders = <int, String>{}.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  @override
  void onInit() {
    super.onInit();

    fetchOrders();
  }


  void fetchOrders() {

    final Stream<QuerySnapshot> orderStream = _firestore.collection('orders').snapshots();


    orders.bindStream(orderStream.map((querySnapshot) {

      return querySnapshot.docs.map((doc) {

        final data = doc.data() as Map<String, dynamic>;


        data['docId'] = doc.id;

        return data;
      }).toList();
    }));
  }



  List<Map<String, dynamic>> getAllProductsFromOrders() {
    final List<Map<String, dynamic>> allProducts = [];

    for (var order in orders) {
      final orderId = order["id"] ?? order["docId"] ?? "";

      final String shopName = (order["items"] as List).isNotEmpty
          ? order["items"][0]['shopName'] ?? "Unknown Shop"
          : "Unknown Shop";

      if (order["items"] is List) {
        for (var item in order["items"]) {
          if (item is Map<String, dynamic>) {
            allProducts.add({
              "orderId": orderId,
              "shopName": shopName,
              "name": item["productName"] ?? item["name"] ?? "",
              "id": item["id"] ?? "",
              "qty": item["count"]?.toString() ?? item["productQty"]?.toString() ?? "1",
              "price": item["productPrice"]?.toString() ?? "0",
              "yourPrice": item["yourprice"]?.toString() ?? "",
              "option": (item["foodType"]?.toLowerCase() == "veg") ? "veg" : "nonveg",
              "image": item["imageUrl"] ?? "",
              "category": item["mainCategory"] ?? "",
              "subCategory": item["subCategory"] ?? "",
              "status": order["status"] ?? "",
            });
          }
        }
      }
    }

    return allProducts;
  }

  String _formatTime(dynamic timestamp) {
    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        date = DateTime.tryParse(timestamp) ?? DateTime.now();
      } else {
        return "";
      }
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      final suffix = date.hour >= 12 ? "PM" : "AM";
      return "$hour:$minute $suffix";
    } catch (_) {
      return "";
    }
  }


  Future<String> getImageUrl(String fileName) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('product_images/krishnamayam/$fileName');

      return await ref.getDownloadURL();
    } catch (e) {
      print('🔥 Error getting image URL: $e');
      return '';
    }
  }
}