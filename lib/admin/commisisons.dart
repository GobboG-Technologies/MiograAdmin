import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/commissionsController.dart';

class CommissionGSTPage extends StatelessWidget {
  final CommissionGSTController controller = Get.put(CommissionGSTController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 4,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: 500, // Adjust for responsiveness
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Commissions", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                  SizedBox(height: 10),

                  /// Incentive Field
                  _buildInputField("Insentive", "%", controller.incentiveController),
                  SizedBox(height: 10),

                  /// Delivery Distance Field
                  _buildInputField("Delivery Distance", "₹/KM", controller.deliveryDistanceController),
                  SizedBox(height: 20),

                  /// Section Title
                  Text(
                    "Commission & GST",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple[900]),
                  ),
                  SizedBox(height: 10),

                  /// Commission & GST Fields
                  _buildCommissionRow("Food", controller.foodCommissionController, controller.foodGSTController),
                  _buildCommissionRow("Fresh Cut", controller.freshCutCommissionController, controller.freshCutGSTController),
                  _buildCommissionRow("Pharmacy",controller.pharmacyCommissionController, controller.pharmacyGSTController),
                  SizedBox(height: 20),

                  /// Buttons (Close & Save)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton("Close", Colors.orange, Colors.orange[800]!,() { Get.back();}),
                      SizedBox(width: 20),
                      _buildButton("Save", Colors.purple, Colors.purple[900]!,(){}),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build Single Input Field (Label + TextField)
  Widget _buildInputField(String label, String suffix, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            hintText: suffix,
            suffixText: suffix,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  ///  Build Commission & GST Row
  Widget _buildCommissionRow(String label, TextEditingController commissionController, TextEditingController gstController) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          Expanded(flex: 1, child: _buildSmallInputField("%", commissionController)),
          SizedBox(width: 10),
          Expanded(flex: 1, child: _buildSmallInputField("GST (%)", gstController)),
        ],
      ),
    );
  }

  ///  Small Input Fields
  Widget _buildSmallInputField(String hint, TextEditingController controller) {
    return  TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
      ),
    );
  }

  ///  Buttons
  Widget _buildButton(String text, Color borderColor, Color textColor,VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: borderColor),
        ),
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
      child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
    );
  }
}
