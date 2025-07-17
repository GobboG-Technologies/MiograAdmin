import 'OrderItemModel.dart';


class OrderModel {
  final String docId;
  final String status;
  final List<OrderItemModel> items;

  OrderModel({
    required this.docId,
    required this.status,
    required this.items,
  });

  factory OrderModel.fromMap(String docId, Map<String, dynamic> data) {
    final itemsData = data['items'] as List? ?? [];

    return OrderModel(
      docId: docId,
      status: data['status'] ?? '',
      items: itemsData.map((e) => OrderItemModel.fromMap(e)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }
}
