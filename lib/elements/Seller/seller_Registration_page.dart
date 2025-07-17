
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../controller/sellerRegistrationCon.dart';

class SellerRegistrationPage extends StatelessWidget {
  final SellerFormController controller = Get.put(SellerFormController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Center(
        child: Container(
          width: 400,
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

                SizedBox(height: 15),

                // Username Field
                _buildTextField(
                  controller.usernameController,
                  "User Name",
                  Icons.person,
                      (value) => value!.isEmpty ? "Enter username" : null,
                ),
                SizedBox(height: 15),

                // Phone Number Field
                _buildTextField(
                  controller.phoneController,
                  "Phone Number",
                  Icons.phone,
                      (value) => value!.isEmpty ? "Enter phone number" : null,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 15),

                // Email Field
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

                // Password Field
                _buildTextField(
                  controller.passwordController,
                  "Password",
                  Icons.lock,
                      (value) =>
                  value!.length < 6 ? "Password must be 6+ characters" : null,
                  isPassword: true,
                ),
                SizedBox(height: 15),

                // Confirm Password Field
                _buildTextField(
                  controller.confirmPasswordController,
                  "Confirm Password",
                  Icons.lock,
                      (value) {
                    if (value!.isEmpty) return "Confirm password";
                    if (value != controller.passwordController.text)
                      return "Passwords do not match";
                    return null;
                  },
                  isPassword: true,
                ),

                SizedBox(height: 15),

                // Submit Button
                ElevatedButton(
                  onPressed: controller.submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text("Create New Seller",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable TextField
  Widget _buildTextField(
      TextEditingController controller,
      String hintText,
      IconData icon,
      String? Function(String?)? validator, {
        TextInputType keyboardType = TextInputType.text,
        bool isPassword = false,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.purple[900]),
          filled: true,
          fillColor: Colors.purple[10],
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
