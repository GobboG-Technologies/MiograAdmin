import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class OrderCard extends StatelessWidget {
  final String orderId;
  final String amount;
  final String date;
  final String location;
  final String paymentMethod;
  //final String paymentIcon;

  OrderCard({
    required this.orderId,
    required this.amount,
    required this.date,
    required this.location,
    required this.paymentMethod,
   // required this.paymentIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
     // width: 320, // Adjust width for responsiveness
      //height: 100,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order ID : $orderId",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Text(
                "₹ $amount",
                style: TextStyle(
                  color: Colors.purple.shade900,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              _getPaymentBadge(paymentMethod),
              //Image.asset(paymentIcon, width: 35), // Payment method logo
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                date,
                style: TextStyle(color: const Color(0xFF7B5BA6), fontSize: 12),
              ),
              Spacer(),
              Icon(Icons.location_on, color: Colors.purple.shade900, size: 16),
              SizedBox(width: 5),
              Text(
                location,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _getPaymentBadge(String method) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: method == "COD" ? Colors.blue.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        method,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: method == "COD" ? Colors.blue : Colors.green),
      ),
    );
  }
}



class OrdersController extends GetxController {
  var orders = [
    {
      "orderId": "ORID9876543210987654",
      "amount": "1160",
      "date": "29/Jun/2024",
      "location": "Thuckalay",
      "paymentMethod": "COD",
      "paymentIcon": "assets/images/cod.png",
    },
    {
      "orderId": "ORID9876543210987654",
      "amount": "1160",
      "date": "29/Jun/2024",
      "location": "Marthandam",
      "paymentMethod": "UPI",
      "paymentIcon": "assets/images/upi.png",
    },
    {
      "orderId": "ORID9876543210987654",
      "amount": "1160",
      "date": "29/Jun/2024",
      "location": "Thuckalay",
      "paymentMethod": "UPI",
      "paymentIcon": "assets/images/upi.png",
    },
    {
      "orderId": "ORID9876543210987654",
      "amount": "1160",
      "date": "29/Jun/2024",
      "location": "Nagercoil",
      "paymentMethod": "COD",
      "paymentIcon": "assets/images/cod.png",
    },
    {
      "orderId": "ORID9876543210987654",
      "amount": "1160",
      "date": "29/Jun/2024",
      "location": "Nagercoil",
      "paymentMethod": "UPI",
      "paymentIcon": "assets/images/cod.png",
    },
  ].obs;
}
