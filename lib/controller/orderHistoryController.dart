import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class OrderHistoryController extends GetxController {
  var selectedOrder = {}.obs;

  void setSelectedOrder(Map<String, dynamic> orders) {
    selectedOrder.value = orders;
  }
  var historyData = <Map<String, dynamic>>[
    {
      "orderId": "ORID9876543210987654",
      "email": "useremail@gmail.com",
      "businessId": "ORID9876543210987654",
      "delivery": "ORID9876543210987654",
      "deliveredTime": "09:30 AM",
      "amount": "100",
      "commission": "7",
      "incentive": "3",
      "gst": "18",
      "deliveryCharge": "2",
      "shopName": "Arya Bhavan",
      "items": [
        {
          "name": "Idli + Sambar + Vadai + Chutney",
          "id": "PID98765432101",
          "image": "assets/images/idili.png"
        },
        {
          "name": "Idli + Sambar + Chutney",
          "id": "PID98765432101",
          "image": "assets/images/idili.png"
        }
      ],
      "businessAddress": "10/5C, Moolachal, Manali, Thuckalay, Kayakumari, 629175, Tamil Nadu.",
      "deliveryAddress": "10/5C, Moolachal, Manali, Thuckalay, Kayakumari, 629175, Tamil Nadu.",
      "time": "09:35 AM",
      "date": "29/Jun/2024",
      "amount": "₹130",
      "paymentMethod": "COD",
      "shopId": "SID98765432101"

    },
    {
      "orderId": "ORID9876543210987655",
      "email": "useremail@gmail.com",
      "businessId": "ORID9876543210987654",
      "delivery": "ORID9876543210987654",
      "deliveredTime": "09:30 AM",
      "amount": "100",
      "commission": "7",
      "incentive": "3",
      "gst": "18",
      "deliveryCharge": "2",
      "shopName": "Arya Bhavan",
      "items": [
        {
          "name": "Idli + Sambar + Vadai + Chutney",
          "id": "PID98765432101",
          "image": "assets/images/idili.png"
        },
        {
          "name": "Idli + Sambar + Chutney",
          "id": "PID98765432101",
          "image": "assets/images/idili.png"
        }
      ],
      "businessAddress": "10/5C, Moolachal, Manali, Thuckalay, Kayakumari, 629175, Tamil Nadu.",
      "deliveryAddress": "10/5C, Moolachal, Manali, Thuckalay, Kayakumari, 629175, Tamil Nadu.",
      "time": "09:35 AM",
      "date": "29/Jun/2024",
      "amount": "₹130",
      "paymentMethod": "UPI",
      "shopId": "SID98765432101"

    }
  ].obs;



}
