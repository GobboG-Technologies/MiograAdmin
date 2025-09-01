import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/EditDeliveryPersonController.dart';

class EditDeliveryPersonPage extends StatelessWidget {
  final String deliveryPersonId;

  EditDeliveryPersonPage({required this.deliveryPersonId}) {
    Get.put(EditDeliveryPersonController(deliveryPersonId));
  }

  @override
  Widget build(BuildContext context) {
    final EditDeliveryPersonController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Delivery Person",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.purple[900],
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: Colors.purple[900]));
        }
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1100), // keeps it centered like Windows form
            child: SingleChildScrollView(
              padding: EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileImageSection(controller),
                  SizedBox(height: 32),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: _buildFormFields(controller),
                    ),
                  ),
                  SizedBox(height: 40),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.update, color: Colors.white),
                      onPressed: controller.updateDeliveryPerson,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[900],
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 22),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      label: Text(
                        "Update Details",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
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

  Widget _buildProfileImageSection(EditDeliveryPersonController controller) {
    return Column(
      children: [
        Obx(() => CircleAvatar(
          radius: 70,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: controller.profileImageUrl.isNotEmpty
              ? NetworkImage(controller.profileImageUrl.value)
              : null,
          child: controller.profileImageUrl.isEmpty
              ? Icon(Icons.person, size: 70, color: Colors.grey.shade600)
              : null,
        )),
        SizedBox(height: 16),
        TextButton.icon(
          icon: Icon(Icons.camera_alt, color: Colors.purple[900]),
          label: Text("Change Profile Image", style: TextStyle(color: Colors.purple[900], fontSize: 16)),
          onPressed: () =>
              controller.pickAndUploadFile(controller.phoneController.text.trim(), isProfileImage: true),
        ),
      ],
    );
  }

  Widget _buildFormFields(EditDeliveryPersonController controller) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 24,
      mainAxisSpacing: 20,
      childAspectRatio: 4.5,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildTextField("Full Name", controller.nameController),
        _buildTextField("Phone Number", controller.phoneController, keyboardType: TextInputType.phone),
        _buildTextField("Email Address", controller.emailController, keyboardType: TextInputType.emailAddress),
        _buildTextField("WhatsApp Number", controller.whatsappController, keyboardType: TextInputType.phone),
        _buildTextField("Full Address", controller.addressController),
        _buildTextField("Driving License Number", controller.drivingLicenseController),
        _buildTextField("Emergency Contact 1", controller.emergencyContact1Controller, keyboardType: TextInputType.phone),
        _buildTextField("Emergency Contact 2", controller.emergencyContact2Controller, keyboardType: TextInputType.phone),
        _buildTextField("Aadhar Number", controller.aadharController),
        _buildTextField("PAN Number", controller.panController),
        _buildTextField("Bank Account Number", controller.accountNoController),
        _buildTextField("IFSC Code", controller.ifscController),
        _buildTextField("UPI ID", controller.upiController),
        _buildTextField("Assigned Zone ID", controller.zoneIdController),
        _buildFilePickerField("Aadhar Card URL", controller.aadharUrlController),
        _buildFilePickerField("PAN Card URL", controller.panUrlController),
        _buildFilePickerField("Driving License URL", controller.dlUrlController),
        _buildFilePickerField("Bank Passbook URL", controller.bankPassbookUrlController),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildFilePickerField(String label, TextEditingController ctrl) {
    final EditDeliveryPersonController controller = Get.find();
    return TextFormField(
      controller: ctrl,
      readOnly: true,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade100,
        suffixIcon: IconButton(
          icon: Icon(Icons.upload_file, color: Colors.purple[900]),
          onPressed: () async {
            String? url = await controller.pickAndUploadFile(controller.phoneController.text.trim());
            if (url != null) {
              ctrl.text = url;
            }
          },
        ),
      ),
    );
  }
}
