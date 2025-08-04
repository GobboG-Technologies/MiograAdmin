import 'OrderRequestItemModel.dart';

class OrderRequestModel {
  final String id;
  final String acceptedBy;
  final List<String> categories;
  final Map<String, dynamic> deliveryAddress;
  final String createdBy;
  final bool isDeliveryAddress;
  final bool isSelected;
  final String phoneNumber;
  final String pincode;
  final String receiverName;
  final String type;
  final Map<String, dynamic> deliveryBoyLocation;
  final String deliveryStatus;
  final bool isGlobalCart;
  final List<OrderRequestItemModel> items;
  final String otp;
  final String paymentId;
  final String status;
  final int totalPrice;
  final String userId;
  final String zoneId;

  OrderRequestModel({
    required this.id,
    required this.acceptedBy,
    required this.categories,
    required this.deliveryAddress,
    required this.createdBy,
    required this.isDeliveryAddress,
    required this.isSelected,
    required this.phoneNumber,
    required this.pincode,
    required this.receiverName,
    required this.type,
    required this.deliveryBoyLocation,
    required this.deliveryStatus,
    required this.isGlobalCart,
    required this.items,
    required this.otp,
    required this.paymentId,
    required this.status,
    required this.totalPrice,
    required this.userId,
    required this.zoneId,
  });

  factory OrderRequestModel.fromMap(String docId, Map<String, dynamic> map) {
    return OrderRequestModel(
      id: docId,
      acceptedBy: map['acceptedBy'] ?? '',
      categories: List<String>.from(map['categories'] ?? []),
      deliveryAddress: Map<String, dynamic>.from(map['deliveryAddress'] ?? {}),
      createdBy: map['createdBy']?.toString() ?? '',
      isDeliveryAddress: map['isDeliveryAddress'] ?? false,
      isSelected: map['isSelected'] ?? false,
      phoneNumber: map['phoneNumber'] ?? '',
      pincode: map['pincode'] ?? '',
      receiverName: map['receiverName'] ?? '',
      type: map['type'] ?? '',
      deliveryBoyLocation: Map<String, dynamic>.from(map['deliveryBoyLocation'] ?? {}),
      deliveryStatus: map['deliveryStatus'] ?? '',
      isGlobalCart: map['isGlobalCart'] ?? false,
      items: (map['items'] as List<dynamic>? ?? [])
          .map((item) => OrderRequestItemModel.fromMap(item))
          .toList(),
      otp: map['otp'] ?? '',
      paymentId: map['paymentId'] ?? '',
      status: map['status'] ?? '',
      totalPrice: (map['totalPrice'] ?? 0).toInt(),
      userId: map['userId'] ?? '',
      zoneId: map['zoneId'] ?? '',
    );
  }
}
