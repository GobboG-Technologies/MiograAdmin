import 'OrderHistoryItemModel.dart';
import 'order_history_item_model.dart';

class OrderHistoryModel {
  final String orderId;
  final String email;
  final String businessId;
  final String delivery;
  final String deliveredTime;
  final String amount;
  final String commission;
  final String incentive;
  final String gst;
  final String deliveryCharge;
  final String shopName;
  final List<OrderHistoryItemModel> items;
  final String businessAddress;
  final String deliveryAddress;
  final String time;
  final String date;
  final String paymentMethod;
  final String shopId;

  OrderHistoryModel({
    required this.orderId,
    required this.email,
    required this.businessId,
    required this.delivery,
    required this.deliveredTime,
    required this.amount,
    required this.commission,
    required this.incentive,
    required this.gst,
    required this.deliveryCharge,
    required this.shopName,
    required this.items,
    required this.businessAddress,
    required this.deliveryAddress,
    required this.time,
    required this.date,
    required this.paymentMethod,
    required this.shopId,
  });

  factory OrderHistoryModel.fromMap(Map<String, dynamic> map) {
    return OrderHistoryModel(
      orderId: map['orderId'] ?? '',
      email: map['email'] ?? '',
      businessId: map['businessId'] ?? '',
      delivery: map['delivery'] ?? '',
      deliveredTime: map['deliveredTime'] ?? '',
      amount: map['amount'] ?? '',
      commission: map['commission'] ?? '',
      incentive: map['incentive'] ?? '',
      gst: map['gst'] ?? '',
      deliveryCharge: map['deliveryCharge'] ?? '',
      shopName: map['shopName'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((item) => OrderHistoryItemModel.fromMap(item))
          .toList(),
      businessAddress: map['businessAddress'] ?? '',
      deliveryAddress: map['deliveryAddress'] ?? '',
      time: map['time'] ?? '',
      date: map['date'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      shopId: map['shopId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'orderId': orderId,
    'email': email,
    'businessId': businessId,
    'delivery': delivery,
    'deliveredTime': deliveredTime,
    'amount': amount,
    'commission': commission,
    'incentive': incentive,
    'gst': gst,
    'deliveryCharge': deliveryCharge,
    'shopName': shopName,
    'items': items.map((e) => e.toMap()).toList(),
    'businessAddress': businessAddress,
    'deliveryAddress': deliveryAddress,
    'time': time,
    'date': date,
    'paymentMethod': paymentMethod,
    'shopId': shopId,
  };
}
