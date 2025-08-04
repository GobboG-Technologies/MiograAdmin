class OrderRequestItemModel {
  final String id;
  final String productName;
  final String description;
  final String foodType;
  final String imageUrl;
  final String mainCategory;
  final String subCategory;
  final String shopId;
  final String shopName;
  final String productPrice;
  final String productQty;
  final String productStatus;
  final String addedBy;
  final int count;
  final String yourPrice;
  final String timestamp;
  final String status;

  OrderRequestItemModel({
    required this.id,
    required this.productName,
    required this.description,
    required this.foodType,
    required this.imageUrl,
    required this.mainCategory,
    required this.subCategory,
    required this.shopId,
    required this.shopName,
    required this.productPrice,
    required this.productQty,
    required this.productStatus,
    required this.addedBy,
    required this.count,
    required this.yourPrice,
    required this.timestamp,
    required this.status,
  });

  factory OrderRequestItemModel.fromMap(Map<String, dynamic> map) {
    return OrderRequestItemModel(
      id: map['id'] ?? '',
      productName: map['productName'] ?? '',
      description: map['description'] ?? '',
      foodType: map['foodType'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      mainCategory: map['mainCategory'] ?? '',
      subCategory: map['subCategory'] ?? '',
      shopId: map['shopId'] ?? '',
      shopName: map['shopName'] ?? '',
      productPrice: map['productPrice'] ?? '',
      productQty: map['productQty'] ?? '',
      productStatus: map['productStatus'] ?? '',
      addedBy: map['addedBy'] ?? '',
      count: (map['count'] ?? 0).toInt(),
      yourPrice: map['yourprice']?.toString() ?? '',
      timestamp: map['timestamp']?.toString() ?? '',
      status: map['status'] ?? '',
    );
  }
}
