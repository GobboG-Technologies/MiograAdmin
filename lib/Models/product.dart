class Product {
  String id;
  String name;
  String imageUrl;
  bool isLive;
  int quantity;
  double sellerPrice;
  double sellingPrice;
  bool option;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isLive,
    required this.quantity,
    required this.sellerPrice,
    required this.sellingPrice,
    required this.option,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String docId) {
    return Product(
      id: docId,
      name: data['productName'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isLive: data['productStatus'] == 'Live',
      quantity: int.tryParse(data['productQty'].toString()) ?? 0,
      sellerPrice: double.tryParse(data['yourprice'].toString()) ?? 0.0,
      sellingPrice: double.tryParse(data['productPrice'].toString()) ?? 0.0,
      option: data['foodType'] == 'Veg', // example logic
    );
  }
}
