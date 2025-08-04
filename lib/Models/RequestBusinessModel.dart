import 'package:get/get.dart';

class RequestBusiness {
  final String name;
  final String address;
  final String id;
  final String location;
  final String imageUrl;
  final bool isLive;

  // Reactive flags
  RxBool isApproved;
  RxBool isRejected;

  // Extra fields
  final String bankName;
  final String gst;
  final String gpayNumber;
  final String upiNumber;
  final String aadhar;
  final String accountNumber;
  final String addedBy;

  RequestBusiness({
    required this.name,
    required this.address,
    required this.id,
    required this.location,
    required this.imageUrl,
    required this.isLive,
    bool isApproved = false,
    bool isRejected = false,
    this.bankName = '',
    this.gst = '',
    this.gpayNumber = '',
    this.upiNumber = '',
    this.aadhar = '',
    this.accountNumber = '',
    this.addedBy = '',
  })  : isApproved = isApproved.obs,
        isRejected = isRejected.obs;
}
