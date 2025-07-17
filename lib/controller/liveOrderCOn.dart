import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class LiveOrderController extends GetxController {
  var selectedTab = 0.obs; // 0 for Order Request, 1 for Live Orders

  final liveorders = [
    {
      "shopId": "SID98765432101",
      "id": "ORID9876543210987654",
      "restaurant": "Arya Bhavan",
      "items": [
        {"name": "Idli + Sambar + Vadai + Chutney", "id": "PID98765432101", "image":"assets/images/img7.png","option":"veg"},
        {"name": "Idli + Sambar + Chutney", "id": "PID98765432102", "image":"assets/images/img8.png","option":"nonveg"},
      ],
      "address": "10/5C, Moolachal, Manali, Thuckalay, Kayakumari, 629175, Tamil Nadu.",
      "paymentMode": "COD",
      "amount": "140",
      "time": "01:00 PM",
      "date": "29/Jun/2024",
      "status": "Pending",
      "address": "Madurai",
      // Initial status
    },
    {
      "shopId": "SID98765432101",
      "id": "ORID9876543210987655",
      "restaurant": "Arya Bhavan",
      "items": [
        {"name": "Idli + Sambar + Vadai + Chutney", "id": "PID98765432103","image":"assets/images/img7.png","option":"nonveg"},
        {"name": "Idli + Sambar + Chutney", "id": "PID98765432104","image":"assets/images/img8.png","option":"veg"},
      ],
      "address": "10/5C, Moolachal, Manali, Thuckalay, Kayakumari, 629175, Tamil Nadu.",
      "paymentMode": "UPI",
      "amount": "160",
      "time": "01:00 PM",
      "date": "29/Jun/2024",
      "status": "Pending",
      "image":"assets/image/idili.png",
      "address": "Madurai",// Initial status
    },
    {
      "id": "ORID9876543210987654",
      "shopId": "SID98765432101",
      "restaurant": "Arya Bhavan",
      "items": [
        {"name": "Idli + Sambar + Vadai + Chutney", "id": "PID98765432101", "image":"assets/images/img7.png","option":"veg"},
        {"name": "Idli + Sambar + Chutney", "id": "PID98765432102", "image":"assets/images/img8.png","option":"nonveg"},
      ],
      "address": "10/5C, Moolachal, Manali, Thuckalay, Kayakumari, 629175, Tamil Nadu.",
      "paymentMode": "COD",
      "amount": "280",
      "time": "01:00 PM",
      "date": "29/Jun/2024",
      "status": "Pending",
      "address": "Madurai",
      // Initial status
    },
    {
      "id": "ORID9876543210987654",
      "shopId": "SID98765432101",
      "restaurant": "Arya Bhavan",
      "items": [
        {"name": "Idli + Sambar + Vadai + Chutney", "id": "PID98765432101", "image":"assets/images/img7.png","option":"veg"},
        {"name": "Idli + Sambar + Chutney", "id": "PID98765432102", "image":"assets/images/img8.png","option":"nonveg"},
      ],
      "address": "10/5C, Moolachal, Manali, Thuckalay, Kayakumari, 629175, Tamil Nadu.",
      "paymentMode": "COD",
      "amount": "280",
      "time": "01:00 PM",
      "date": "29/Jun/2024",
      "status": "Pending",
      "address": "Madurai",
      // Initial status
    },
  ].obs;


}