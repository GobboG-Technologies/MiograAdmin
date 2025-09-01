import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/addDeliveryPersonController.dart';

class AddDeliveryPersonPage extends StatelessWidget {
  final controller = Get.put(DeliveryPersonAddController());

  Widget _buildTextField(String label, TextEditingController ctrl,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.purple[900], fontWeight: FontWeight.w600),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.purple.shade900, width: 2.5),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }

  Widget _buildFilePickerField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: ctrl,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.purple[900], fontWeight: FontWeight.w600),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.purple.shade900, width: 2.5),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          filled: true,
          fillColor: Colors.grey.shade100,
          suffixIcon: IconButton(
            icon: Icon(Icons.upload_file, color: Colors.purple[900]),
            onPressed: () async {
              String phone = controller.phoneController.text.trim();
              if (phone.isEmpty) {
                Get.snackbar("Error", "Please enter a phone number first.",
                    backgroundColor: Colors.red.shade200,
                    colorText: Colors.red.shade900,
                    snackPosition: SnackPosition.BOTTOM);
                return;
              }

              String? url = await controller.pickAndUploadFile(phone);
              if (url != null) {
                ctrl.text = url;
                Get.snackbar("Success", "$label has been uploaded successfully.",
                    backgroundColor: Colors.green.shade200,
                    colorText: Colors.green.shade900,
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[900]),
            ),
            SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add New Delivery Person",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.purple[900],
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 8,
        shadowColor: Colors.purple.shade100,
      ),
      body: Obx(() {
        return controller.isLoading.value
            ? Center(child: CircularProgressIndicator(color: Colors.purple[900]))
            : Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 1400),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildPersonalInfoSection(),
                      ),
                      Expanded(
                        flex: 2,
                        child: _buildIdentityAndFinancialSection(),
                      ),
                    ],
                  ),
                  _buildDocumentUploadSection(),
                  SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: Icon(Icons.person_add_alt_1, color: Colors.white),
                    onPressed: controller.addDeliveryPerson,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[900],
                      padding: EdgeInsets.symmetric(
                          horizontal: 40, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: Colors.purple.shade200,
                    ),
                    label: Text(
                      "Submit and Add Person",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSectionCard(
      "Personal & Contact Information",
      [
        _buildTextField("Full Name", controller.nameController),
        _buildTextField("Email Address", controller.emailController,
            keyboardType: TextInputType.emailAddress),
        _buildTextField("Phone Number", controller.phoneController,
            keyboardType: TextInputType.phone),
        _buildTextField("WhatsApp Number", controller.whatsappController,
            keyboardType: TextInputType.phone),
        _buildTextField("Full Address", controller.addressController),
        _buildTextField(
            "Emergency Contact 1", controller.emergencyContact1Controller,
            keyboardType: TextInputType.phone),
        _buildTextField(
            "Emergency Contact 2", controller.emergencyContact2Controller,
            keyboardType: TextInputType.phone),
        _buildTextField("Assigned Zone ID", controller.zoneIdController),
      ],
    );
  }

  Widget _buildIdentityAndFinancialSection() {
    return _buildSectionCard(
      "Identity & Financial Details",
      [
        _buildTextField("Driving License Number",
            controller.drivingLicenseController),
        _buildTextField("Aadhar Number", controller.aadharController),
        _buildTextField("PAN Number", controller.panController),
        _buildTextField("Bank Account Number", controller.accountNoController),
        _buildTextField("IFSC Code", controller.ifscController),
        _buildTextField("UPI ID", controller.upiController),
      ],
    );
  }

  Widget _buildDocumentUploadSection() {
    return _buildSectionCard(
      "Document Uploads",
      [
        Row(
          children: [
            Expanded(
              child: _buildFilePickerField(
                  "Upload Aadhar Card", controller.aadharUrlController),
            ),
            SizedBox(width: 24),
            Expanded(
              child: _buildFilePickerField(
                  "Upload PAN Card", controller.panUrlController),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFilePickerField(
                  "Upload Driving License", controller.dlUrlController),
            ),
            SizedBox(width: 24),
            Expanded(
              child: _buildFilePickerField(
                  "Upload Bank Passbook", controller.bankPassbookUrlController),
            ),
          ],
        ),
      ],
    );
  }
}