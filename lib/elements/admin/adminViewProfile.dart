import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../Models/admin_model.dart';
import '../../controller/adminController.dart';

class AdminProfilePreviewPage extends StatelessWidget {
  final AdminModel admin;

  AdminProfilePreviewPage({required this.admin});
  final AdminControllerpage controller = Get.put(AdminControllerpage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Container(
          width: 350,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image & Info
              _buildProfileHeader(),
              SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _closeButton(Icons.delete, "Delete", Colors.red),
                  _closeButton(Icons.close, "Close", Colors.orange),
                ],
              ),
              SizedBox(height: 20),

              // Bank Details
              _buildBankDetails(),

              SizedBox(height: 30),

              // Uploaded Documents
              _buildDocumentsSection(controller),
            ],
          ),
        ),
      ),
    );
  }

  /// 🖼 Profile Header
  Widget _buildProfileHeader( ) {
    return Column(
      children: [

        CircleAvatar(
          radius: 40,
          backgroundImage: admin.image != null
              ? AssetImage(admin.image)
              : AssetImage("assets/images/img5.png") as ImageProvider,
        ),

        SizedBox(height: 8),
        Text(admin.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text("ID:${admin.id}", style: TextStyle(color: Colors.purple[900])),
        Text("+91${admin.phone}", style: TextStyle(color: Colors.grey)),
        Text(admin.email, style: TextStyle(color: Colors.black)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, color: Colors.purple[900]),
            Text(admin.location,style: TextStyle(color: Colors.grey),),
          ],
        ),
      ],
    );
  }


  Widget _closeButton(IconData icon, String label, Color color) {
    return OutlinedButton(
      onPressed: () => Get.back(),
      style: OutlinedButton.styleFrom(
        side: BorderSide( color: color,width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: Size(120, 50),
      ),
      child: Row(
        children: [
          Icon(icon,color: color),
          Text(label, style: TextStyle(fontSize: 16, color: color)),
        ],
      ),
    );
  }


  /// 🏦 Bank Details Section
  Widget _buildBankDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBankDetailItem("Account Name", admin.name),
        _buildBankDetailItem("Account Number", admin.accountNumber),
        _buildBankDetailItem("IFSC", admin.ifsc),
      ],
    );
  }

  Widget _buildBankDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple[900])),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  /// 📄 Documents Section
  Widget _buildDocumentsSection(AdminControllerpage controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDocumentCard("Aadhar", controller.aadharPdf, () {
          // Upload logic
        }),
        SizedBox(width: 10),
        _buildDocumentCard("Passbook", controller.passbookPdf, () {
          // Upload logic
        }),
      ],
    );
  }

  Widget _buildDocumentCard(String label, Rx<Uint8List?> file, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Obx(() {
        return Container(
          width: 80,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(blurRadius: 2, color: Colors.grey.shade400)],
            border: Border.all(color: file.value != null ? Colors.green : Colors.grey.shade300, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf, color: file.value != null ? Colors.red : Colors.grey, size: 40),
              Text(label, style: TextStyle(fontSize: 12)),
            ],
          ),
        );
      }),
    );
  }
}