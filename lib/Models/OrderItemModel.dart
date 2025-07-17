class OrderItemModel {
  final String name;
  final String id;
  final String qty;
  final String price;
  final String yourPrice;
  final String option;
  final String image;
  final String category;
  final String subCategory;
  final String shopName;

  OrderItemModel({
    required this.name,
    required this.id,
    required this.qty,
    required this.price,
    required this.yourPrice,
    required this.option,
    required this.image,
    required this.category,
    required this.subCategory,
    required this.shopName,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> data) {
    return OrderItemModel(
      name: data['productName'] ?? data['name'] ?? '',
      id: data['id'] ?? '',
      qty: data['count']?.toString() ?? data['productQty']?.toString() ?? '1',
      price: data['productPrice']?.toString() ?? '0',
      yourPrice: data['yourprice']?.toString() ?? '',
      option: (data['foodType']?.toLowerCase() == 'veg') ? 'veg' : 'nonveg',
      image: data['imageUrl'] ?? '',
      category: data['mainCategory'] ?? '',
      subCategory: data['subCategory'] ?? '',
      shopName: data['shopName'] ?? 'Unknown Shop',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': name,
      'id': id,
      'productQty': qty,
      'productPrice': price,
      'yourprice': yourPrice,
      'foodType': option,
      'imageUrl': image,
      'mainCategory': category,
      'subCategory': subCategory,
      'shopName': shopName,
    };
  }
}
