import 'package:get/get_rx/src/rx_types/rx_types.dart';

class DeliveryPerson {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String? imageUrl;
  final RxBool isAvailable;


  DeliveryPerson({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.imageUrl,
    required bool isAvailable}): isAvailable = isAvailable.obs;
}