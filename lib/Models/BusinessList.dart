import 'package:get/get_rx/src/rx_types/rx_types.dart';

class Business {
  final String name;
  final String address;
  final String id;
  final String location;
  final String imageUrl;
  RxBool isLive;
  RxBool isApproved; // To track approval state
  RxBool isRejected;

  Business({
    required this.name,
    required this.address,
    required this.id,
    required this.location,
    required this.imageUrl,
    required bool isLive,
    required bool isApproved,
    required bool isRejected,
  }): isLive = isLive.obs,isApproved = RxBool(isApproved) ,isRejected = RxBool(isRejected);
}