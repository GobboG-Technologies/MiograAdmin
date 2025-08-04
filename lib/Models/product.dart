class Product {
  String id;
  String name;
  String imageUrl;
  bool isLive; // Derived from productStatus == 'Live'
  int quantity;
  double sellerPrice;
  double sellingPrice;
  bool option; // true for Veg, false for Non-Veg
  String shopId; // Needed for zone filtering
  String shopName; // For displaying shop name

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isLive,
    required this.quantity,
    required this.sellerPrice,
    required this.sellingPrice,
    required this.option,
    required this.shopId,
    required this.shopName,
  });

  /// Create Product object from Firestore data
  factory Product.fromFirestore(Map<String, dynamic> data, String docId) {
    return Product(
      id: docId,
      name: data['productName'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isLive: data['productStatus'] == 'Live', // Convert string to bool
      quantity: int.tryParse(data['productQty'].toString()) ?? 0,
      sellerPrice: double.tryParse(data['yourprice'].toString()) ?? 0.0,
      sellingPrice: double.tryParse(data['productPrice'].toString()) ?? 0.0,
      option: data['foodType'] == 'Veg', // true if Veg
      shopId: data['shopId'] ?? '',
      shopName: data['shopName'] ?? '',
    );
  }
}
