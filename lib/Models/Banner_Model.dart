import 'dart:typed_data';

class BannerModel {
  Uint8List imageBytes;
  //String image;
  String name;
  String startDate;
  String endDate;
  String category;
  bool isActive;

  BannerModel({
    required this.imageBytes,
    //required this.image,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.category,
    required this.isActive,
  });
}