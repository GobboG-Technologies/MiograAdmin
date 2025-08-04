import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/LoginController.dart';


class LoginPage extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/loginimage.png",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 400,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Image.asset("assets/images/M.png", height: 80),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          "ADMIN",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5D348B),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Email ID",
                          style: TextStyle(
                            color: Color(0xFF5D348B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextField(
                        controller: controller.emailController,
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Password",
                          style: TextStyle(
                            color: Color(0xFF5D348B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextField(
                        controller: controller.passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF5D348B),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: controller.login,
                          child: Text(
                            "Login",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
