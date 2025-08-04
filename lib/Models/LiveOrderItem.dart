class LiveOrderItem {
  final String name;
  final String id;
  final String image;
  final String option;

  LiveOrderItem({
    required this.name,
    required this.id,
    required this.image,
    required this.option,
  });

  factory LiveOrderItem.fromMap(Map<String, dynamic> map) {
    return LiveOrderItem(
      name: map['name'] ?? '',
      id: map['id'] ?? '',
      image: map['image'] ?? '',
      option: map['option'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'id': id,
    'image': image,
    'option': option,
  };
}

class LiveOrderModel {
  final String id;
  final String shopId;
  final String restaurant;
  final List<LiveOrderItem> items;
  final String address;
  final String paymentMode;
  final String amount;
  final String time;
  final String date;
  final String status;

  LiveOrderModel({
    required this.id,
    required this.shopId,
    required this.restaurant,
    required this.items,
    required this.address,
    required this.paymentMode,
    required this.amount,
    required this.time,
    required this.date,
    required this.status,
  });

  factory LiveOrderModel.fromMap(Map<String, dynamic> map) {
    final itemsData = map['items'] as List? ?? [];

    return LiveOrderModel(
      id: map['id'] ?? '',
      shopId: map['shopId'] ?? '',
      restaurant: map['restaurant'] ?? '',
      items: itemsData.map((e) => LiveOrderItem.fromMap(e)).toList(),
      address: map['address'] ?? '',
      paymentMode: map['paymentMode'] ?? '',
      amount: map['amount'] ?? '',
      time: map['time'] ?? '',
      date: map['date'] ?? '',
      status: map['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'shopId': shopId,
    'restaurant': restaurant,
    'items': items.map((e) => e.toMap()).toList(),
    'address': address,
    'paymentMode': paymentMode,
    'amount': amount,
    'time': time,
    'date': date,
    'status': status,
  };
}
