import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/sellerProfileEditCon.dart';

class SellerProfileEditPage extends StatelessWidget {
  final String? sellerId;
  final ProfileEditController controller = Get.put(ProfileEditController());

  SellerProfileEditPage({Key? key, this.sellerId}) : super(key: key) {
    if (sellerId != null) {
      controller.loadSellerData(sellerId!);
    } else {
      controller.clearForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 3,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.grey.shade300, blurRadius: 10),
            ],
          ),
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Obx(() => Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                      controller.profileImage.value.isNotEmpty
                          ? NetworkImage(controller.profileImage.value)
                          : null,
                      child: controller.profileImage.value.isEmpty
                          ? Icon(Icons.person,
                          size: 50, color: Colors.grey[600])
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        // onTap: controller.pickImages,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.purple[800],
                          child: Icon(Icons.cloud_upload,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                )),
                SizedBox(height: 10),
                Text("User Name",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[900])),
                SizedBox(height: 10),
                _buildTextField(controller.usernameController, "User Name",
                    Icons.person, (value) => value!.isEmpty ? "Enter username" : null),
                _buildTextField(
                  controller.phoneController,
                  "Phone Number",
                  Icons.phone,
                      (value) => value!.isEmpty ? "Enter phone number" : null,
                  keyboardType: TextInputType.phone,
                ),
                _buildTextField(
                  controller.emailController,
                  "Email",
                  Icons.email,
                      (value) => value!.isEmpty || !value.contains('@')
                      ? "Enter valid email"
                      : null,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.orange, width: 2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        minimumSize: Size(100, 50),
                      ),
                      child: Text("Close",
                          style:
                          TextStyle(fontSize: 16, color: Colors.orange)),
                    ),
                    ElevatedButton(
                      onPressed: controller.saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[800],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: Size(100, 50),
                      ),
                      child: Text("Save", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon,
      String? Function(String?) validator,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.purple[800]),
          filled: true,
          fillColor: Colors.purple[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator,
      ),
    );
  }
}

