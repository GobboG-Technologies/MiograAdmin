class OrderHistoryItemModel {
  final String name;
  final String id;
  final String image;

  OrderHistoryItemModel({
    required this.name,
    required this.id,
    required this.image,
  });

  factory OrderHistoryItemModel.fromMap(Map<String, dynamic> map) {
    return OrderHistoryItemModel(
      name: map['name'] ?? '',
      id: map['id'] ?? '',
      image: map['image'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'id': id,
    'image': image,
  };
}
