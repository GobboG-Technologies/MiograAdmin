
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class RequestProduct {
  final String id;
  final String name;
  final String imageUrl;
  final int quantity;
  final double sellerPrice;
  final double sellingPrice;
  bool option;
  RxBool isApproved; // To track approval state
  RxBool isRejected;

  RequestProduct({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.sellerPrice,
    required this.sellingPrice,
    required this.option,
    required bool isApproved,
    required bool isRejected,
  }) : isApproved = RxBool(isApproved) ,isRejected = RxBool(isRejected);
}
