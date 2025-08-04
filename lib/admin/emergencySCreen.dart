import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmergencyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          width: 450, // Adjust width for web responsiveness
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Emergency",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 10),

              // List of Users
              Column(
                children: List.generate(2, (index) => _buildUserCard()),
              ),

              SizedBox(height: 20),

              // Close Button
              _buildCloseButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 User Card Widget
  Widget _buildUserCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Image
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              'assets/images/img1.png', // Replace with actual image URL
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10),

          // User Details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Raju",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "ID: SID98765432101",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔹 Close Button
  Widget _buildCloseButton() {
    return ElevatedButton(
      onPressed: () => Get.back(), // Close the dialog or navigate back
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.orange, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
      child: Text(
        "Close",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.orange),
      ),
    );
  }
}
