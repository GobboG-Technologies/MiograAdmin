class DeliveryPerson {
  final String id;
  String name;
  String phone;
  String address;
  String email;
  String imageUrl;
  bool isAvailable;
  String zoneId; // Important for associating the person with a zone

  DeliveryPerson({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    required this.imageUrl,
    required this.isAvailable,
    required this.zoneId,
  });

  // Factory constructor to create a DeliveryPerson from a Firestore document
  factory DeliveryPerson.fromFirestore(Map<String, dynamic> data, String documentId) {
    return DeliveryPerson(
      id: documentId,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      email: data['email'] ?? '',
      imageUrl: data['profile_image'] ?? '',
      isAvailable: data['status'] == 'online',
      zoneId: data['zoneId'] ?? '',
    );
  }

  // Method to convert a DeliveryPerson object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
      'profile_image': imageUrl,
      'status': isAvailable ? 'online' : 'offline',
      'zoneId': zoneId,
    };
  }
}