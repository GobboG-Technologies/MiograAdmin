import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/EditProductController.dart';
import '../../controller/shopController.dart';
import '../sidebar.dart';
import 'dart:io';




class AddNewProductPage extends StatelessWidget {
  final EditProductController controller = Get.put(EditProductController());
  final ShopController controllerS = Get.put(ShopController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 800;

          return Row(
            children: [
              if (!isMobile)
                Sidebar(),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add New Product",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[900],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => Get.back(),
                            icon: Icon(Icons.arrow_back_ios),
                            label: Text("Back"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[900],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 30),

                      // Product Image Upload
                      Obx(() {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: controller.selectedImage.value == null
                                  ? Container(
                                width: double.infinity,
                                height: 287,
                                color: Colors.grey[300],
                                child: Icon(Icons.image, size: 100, color: Colors.grey[600]),
                              )
                                  : Image.file(
                                File(controller.selectedImage.value!.path), // ✅ Fixed here
                                width: double.infinity,
                                height: 287,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () => controller.pickImage(),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.camera_alt, color: Colors.purple[900]),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),


                      SizedBox(height: 20),

                      // Product Status Section
                      _buildSectionTitle("Product Status"),
                      Obx(() => Row(
                        children: [
                          _buildRadioTile("Paused", controller.productStatus.value,
                                  (value) => controller.productStatus.value = value!),
                          _buildRadioTile("Visible", controller.productStatus.value,
                                  (value) => controller.productStatus.value = value!),
                        ],
                      )),

                      SizedBox(height: 20),

                      // Food Type Section
                      _buildSectionTitle("Food Type"),
                      Obx(() => Row(
                        children: [
                          _buildRadioTileWithIcon("Veg", Icons.eco, Colors.green, controller.foodType.value,
                                  (value) => controller.foodType.value = value!),
                          _buildRadioTileWithIcon("Non Veg", Icons.restaurant, Colors.red, controller.foodType.value,
                                  (value) => controller.foodType.value = value!),
                        ],
                      )),

                      SizedBox(height: 20),

                      // Food Type Section
                      _buildSectionTitle("mainCategory"),
                      Obx(() => Row(
                        children: [
                          _buildRadioTileWithIcon("Food", Icons.fastfood_outlined, Colors.yellow, controller.mainCategory.value,
                                  (value) => controller.foodType.value = value!),
                          _buildRadioTileWithIcon("FreshCut", Icons.set_meal, Colors.blueGrey, controller.mainCategory.value,
                                  (value) => controller.foodType.value = value!),
                          _buildRadioTileWithIcon("Daily Mio", Icons.shopping_bag, Colors.red, controller.mainCategory.value,
                                  (value) => controller.foodType.value = value!),
                          _buildRadioTileWithIcon("Pharmacy ", Icons. vaccines, Colors. lightBlueAccent , controller.mainCategory.value,
                                  (value) => controller.foodType.value = value!),
                        ],
                      )),
                      _buildSectionTitle("selectedSubcategory"),
                      SizedBox(height: 12),
                      _buildDropdownField("Select Subcategory", controller.selectedSubcategory, controller.subcategories),



                      SizedBox(height: 20),

                      // Product Details
                      _buildSectionTitle("Product Details"),
                      _buildTextField("Name", controller.productName),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPriceInput("Product Price", controller.productPrice),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildPriceInput("Your Price", controller.yourprice),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),
                      _buildMultilineField("Description", controller.description),
                      SizedBox(height: 12),
                      _buildQuantityInput("Quantity", controller.productQty),
                      SizedBox(height: 12),
                      _buildQuantityInput("sellerId", controller.sellerId),
                      SizedBox(height: 12),
                      _buildQuantityInput("businessId", controller.businesId),
                      SizedBox(height: 12),
                      _buildQuantityInput("shopId", controller.shopId),
                      SizedBox(height: 12),
                      _buildQuantityInput("shopName", controller.shopName),
                      SizedBox(height: 30),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (controller.productName.text.isEmpty || controller.productPrice.text.isEmpty) {
                              Get.snackbar("Validation", "Please fill in required fields",
                                  backgroundColor: Colors.orange, colorText: Colors.white);
                              return;
                            }

                            await controller.addProductToFirestore();
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[900],
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text("Add Product", style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple[900]));
  }

  // Radio Tile
  Widget _buildRadioTile(String title, String groupValue, void Function(String?) onChanged) {
    return Expanded(
      child: RadioListTile<String>(
        title: Text(title),
        value: title,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: Colors.purple[900],
      ),
    );
  }

  // Radio with Icon
  Widget _buildRadioTileWithIcon(String title, IconData icon, Color iconColor, String groupValue, void Function(String?) onChanged) {
    return Expanded(
      child: RadioListTile<String>(
        title: Row(
          children: [
            Icon(icon, color: iconColor),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        value: title,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: Colors.purple[900],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
    );
  }



  Widget _buildPriceInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple[900])),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "₹",
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildMultilineField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 5,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
    );
  }
  //
  Widget _buildQuantityInput(String label, TextEditingController controller) {
    return _buildTextField(label, controller);
  }


  Widget _buildDropdownField(String label, RxString selectedValue, List<String> items) {
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: selectedValue.value.isEmpty ? null : selectedValue.value,
        hint: Text(label),
        isExpanded: true,
        underline: SizedBox(),
        icon: Icon(Icons.arrow_drop_down),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (value) {
          selectedValue.value = value!;
        },
      ),
    ));
  }

}