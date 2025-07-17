class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String image;
  final String houseName;
  final String houseNo;
  final String landmark;
  final String pincode;
  final String street;
  final String status;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.image,
    required this.houseName,
    required this.houseNo,
    required this.landmark,
    required this.pincode,
    required this.street,
    required this.status,
  });

  factory Customer.fromFirestore(Map<String, dynamic> data, String docId) {
    return Customer(
      id: docId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      image: data['image'] ?? 'assets/images/img5.png', // default image
      houseName: data['house name'] ?? '',
      houseNo: data['house no'] ?? '',
      landmark: data['landmark'] ?? '',
      pincode: data['pincode'] ?? '',
      street: data['street'] ?? '',
      status: data['status'] ?? '',
    );
  }
}
