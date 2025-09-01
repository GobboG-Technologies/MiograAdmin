import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final String zoneId;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.zoneId,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] != null)
          ? double.tryParse(data['price'].toString()) ?? 0.0
          : 0.0,
      imageUrl: data['imageUrl'] ?? '',
      zoneId: data['zoneId'] ?? '',
    );
  }
}

class blockProductController extends GetxController {
  var products = <Product>[].obs;

  // 🔹 Zone handling
  var zones = <Map<String, dynamic>>[].obs;
  var selectedZoneId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _loadZonesFromSession();
  }

  /// 🔹 Load zones stored in session
  Future<void> _loadZonesFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('adminSession');
    if (sessionJson == null) return;

    final sessionData = jsonDecode(sessionJson);
    final List<dynamic> zonesData = sessionData['zonesData'] ?? [];

    zones.assignAll(zonesData.cast<Map<String, dynamic>>());

    final primaryZoneId = sessionData['primaryZoneId'];

    if (primaryZoneId != null &&
        zones.any((z) => z['zoneId'] == primaryZoneId)) {
      selectedZoneId.value = primaryZoneId;
      fetchProductsByZone(primaryZoneId);
    } else if (zones.isNotEmpty) {
      selectedZoneId.value = zones.first['zoneId'];
      fetchProductsByZone(zones.first['zoneId']);
    }
  }

  /// 🔹 When dropdown zone is changed
  Future<void> onZoneChanged(String? newZoneId) async {
    if (newZoneId == null) return;
    selectedZoneId.value = newZoneId;
    fetchProductsByZone(newZoneId);
  }

  /// 🔹 Fetch products by zone
  Future<void> fetchProductsByZone(String zoneId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Products')
          .where('zoneId', isEqualTo: zoneId)
          .get();

      final productsData = snapshot.docs.map((doc) {
        return Product.fromFirestore(doc.data(), doc.id);
      }).toList();

      products.assignAll(productsData);
    } catch (e) {
      print("Error fetching products: $e");
    }
  }
}
