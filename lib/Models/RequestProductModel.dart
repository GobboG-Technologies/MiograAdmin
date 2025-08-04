import 'package:get/get_rx/src/rx_types/rx_types.dart';

class RequestProduct {
  String id;
  String name;
  String imageUrl;
  int quantity;
  double sellerPrice;
  double sellingPrice;
  bool option;
  RxBool isApproved;
  RxBool isRejected;

  RequestProduct({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.sellerPrice,
    required this.sellingPrice,
    required this.option,
    required this.isApproved,
    required this.isRejected,
  });
}
