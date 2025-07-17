
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../controller/adminController.dart';
import '../../example.dart';

class AdminRegistrationPage extends StatelessWidget {
  final AdminControllerpage controller = Get.put(AdminControllerpage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child:Center(
            child: Container(
              width: 400,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Personal Details", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  _buildTextField("Name",controller.nameController),
                  SizedBox(height: 10),
                  _buildTextField("Contact",controller.contactController),
                  SizedBox(height: 10),
                  _buildTextField("Email",controller.emailController),
                  SizedBox(height: 10),
                  _buildDropdown("Zone"),
                  SizedBox(height: 10),
                  Text("Profile Picture"),
                  _buildProfilePicture(controller),
                  SizedBox(height: 10),
                  Text("Bank Details", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  _buildTextField("Account Name",controller.accountnameController),
                  SizedBox(height: 10),
                  _buildTextField("Account Number",controller.accountnumberController),
                  SizedBox(height: 10),
                  _buildTextField("IFSC Code",controller.ifscController),
                  SizedBox(height: 10),
                  _buildUploadButton("Aadhar",),
                  SizedBox(height: 10),
                  _buildUploadButton("Bank Passbook"),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _closeButton("Close", ),
                      _buildButton("+ Add", ),
                    ],
                  ),
                ],
              ),
            ),
          ) ),
    );
  }

  Widget _buildTextField(String label,TextEditingController controller) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // Background color
        borderRadius: BorderRadius.circular(5), // Rounded corners
      ),
      padding: EdgeInsets.symmetric(horizontal: 15,),

      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: label,
        ),
      ),
    );
  }

  Widget _buildDropdown(String label) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // Background color
        borderRadius: BorderRadius.circular(5), // Rounded corners
      ),
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: DropdownButtonFormField(
        items: ["Zone 1", "Zone 2"].map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
        onChanged: (value) {},
        decoration: InputDecoration(
            hintText: label,
            border:InputBorder.none
        ),
      ),
    );
  }

  Widget _buildProfilePicture(AdminControllerpage controller) {
    return GestureDetector(
      onTap: () => controller.pickProfileImage(),
      child: Obx(() {
        return Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
              // image: controller.profileImage.value != null
              //     ? DecorationImage(image: FileImage(controller.profileImage.value!), fit: BoxFit.cover)
              //     : null,
            ),
            child: controller.profileImage.value != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                controller.profileImage.value!,
                fit: BoxFit.cover,
              ),
            )
                : Icon(Icons.image, color: Colors.grey),

          ),
        );
      }),
    );

  }


  /// **Upload Button for Documents**
  Widget _buildUploadButton(String documentType) {
    return GestureDetector(
      onTap: () => controller.uploadDocument(documentType),
      child: Obx(() {
        bool isUploaded = controller.uploadedDocuments.containsKey(documentType) &&
            controller.uploadedDocuments[documentType] == true;

        return Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          margin: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: isUploaded ? Colors.green : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(5),
            color: isUploaded ? Colors.green.shade50 : Colors.grey.shade100,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.red),
                  SizedBox(width: 10),
                  Text(documentType,style: TextStyle(color: Colors.grey),),
                ],
              ),
              if (isUploaded) Icon(Icons.check_circle, color: Colors.green),
              if (!isUploaded) Icon(Icons.upload, color: Colors.grey),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildButton(String label,) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: Size(120, 50),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(label,style: TextStyle(color: Colors.white),),
    );
  }

  Widget _closeButton(String label,) {
    return OutlinedButton(
      onPressed: () => Get.back(),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.orange, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: Size(120, 50),
      ),
      child: Text("Close", style: TextStyle(fontSize: 16, color: Colors.orange)),
    );
  }
}