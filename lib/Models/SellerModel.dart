import 'package:get/get.dart';

class Sellers {
  String id;
  String name;
  String phone;
  String email;
  String imageUrl;
  RxBool isLive;  // reactive boolean
  String address;

  Sellers({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.imageUrl,
    required bool isLive,
    required this.address,
  }) : isLive = RxBool(isLive);

  // Factory constructor to create a Sellers object from Firestore map data
  factory Sellers.fromMap(Map<String, dynamic> map, String docId) {
    return Sellers(
      id: docId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isLive: map['isLive'] ?? false,
      address: map['address'] ?? '',
    );
  }

  // Converts Sellers object back to map for Firestore update
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'imageUrl': imageUrl,
      'isLive': isLive.value,
      'address': address,
    };
  }
}
