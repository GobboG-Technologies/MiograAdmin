import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final storeId = Get.arguments['storeId'];
    final price = Get.arguments['price'];
    final name = Get.arguments['name'];
    final image = Get.arguments['image'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(image), // Example image
              ),
              SizedBox(height: 10),
              Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text("ID: $storeId", style: TextStyle(color: Colors.purple[900], fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("₹ $price", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Get.back(); // Close the payment page
                    },
                    child: Text("Close", style: TextStyle(color: Colors.orange)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Handle the payment action
                      print("Processing Payment of ₹$price for Store ID: $storeId");
                    },
                    icon: Text("pay", style: TextStyle(color: Colors.white)),
                    label: Text("Pay Now", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
