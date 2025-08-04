import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'dart:io';

import '../../controller/UpdateProductController.dart';
import '../../controller/shopController.dart';
import '../sidebar.dart';

class UpdateProductPage extends StatelessWidget {
  final String productId;

  UpdateProductPage({required this.productId});

  @override
  Widget build(BuildContext context) {
    final UpdateProductController controller = Get.put(UpdateProductController(productId));
    final ShopController controllerS = Get.put(ShopController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 800;

          return Row(
            children: [
              if (!isMobile) Sidebar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Obx(() {
                    // Wait until data is fetched (optional: you can have a loading bool)
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Update Product",
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

                        // Image Upload
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _buildImageWidget(controller),
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
                        ),

                        SizedBox(height: 20),

                        // Product Status Section
                        _buildSectionTitle("Product Status"),
                        Row(
                          children: [
                            Flexible(
                              child: _buildRadioTile("Paused", controller.productStatus.value,
                                      (value) => controller.productStatus.value = value!),
                            ),
                            Flexible(
                              child: _buildRadioTile("Visible", controller.productStatus.value,
                                      (value) => controller.productStatus.value = value!),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Food Type Section
                        _buildSectionTitle("Food Type"),
                        Row(
                          children: [
                            Flexible(
                              child: _buildRadioTileWithIcon("Veg", Icons.eco, Colors.green, controller.foodType.value,
                                      (value) => controller.foodType.value = value!),
                            ),
                            Flexible(
                              child: _buildRadioTileWithIcon("Non Veg", Icons.restaurant, Colors.red, controller.foodType.value,
                                      (value) => controller.foodType.value = value!),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Main Category Section - Horizontal scroll added here
                        _buildSectionTitle("Main Category"),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildRadioTileWithIcon("Food", Icons.fastfood_outlined, Colors.yellow, controller.mainCategory.value,
                                      (value) => controller.mainCategory.value = value!),
                              _buildRadioTileWithIcon("FreshCut", Icons.set_meal, Colors.blueGrey, controller.mainCategory.value,
                                      (value) => controller.mainCategory.value = value!),
                              _buildRadioTileWithIcon("Daily Mio", Icons.shopping_bag, Colors.red, controller.mainCategory.value,
                                      (value) => controller.mainCategory.value = value!),
                              _buildRadioTileWithIcon("Pharmacy", Icons.vaccines, Colors.lightBlueAccent, controller.mainCategory.value,
                                      (value) => controller.mainCategory.value = value!),
                            ].map((w) => Padding(padding: EdgeInsets.only(right: 8), child: SizedBox(width: 150, child: w))).toList(),
                          ),
                        ),

                        SizedBox(height: 20),
                        _buildSectionTitle("Sub Category"),
                        SizedBox(height: 12),
                        _buildDropdownField("Select Subcategory", controller.selectedSubcategory, controller.subcategories),

                        SizedBox(height: 20),

                        // Product Details Section
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
                              child: _buildPriceInput("Your Price", controller.yourPrice),
                            ),
                          ],
                        ),

                        SizedBox(height: 12),
                        _buildMultilineField("Description", controller.description),
                        SizedBox(height: 12),
                        _buildQuantityInput("Quantity", controller.productQty),

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
                              await controller.updateProduct();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[900],
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text("Update Product", style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageWidget(UpdateProductController controller) {
    if (controller.selectedImage.value == null) {
      if (controller.selectedImageUrl.value.isEmpty) {
        return Container(
          width: double.infinity,
          height: 287,
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 100, color: Colors.grey[600]),
              SizedBox(height: 8),
              Text(
                "Tap camera icon to add image",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      } else {
        // Show existing image from URL
        return Image.network(
          controller.selectedImageUrl.value,
          width: double.infinity,
          height: 287,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: double.infinity,
            height: 287,
            color: Colors.grey[300],
            alignment: Alignment.center,
            child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
          ),
        );
      }
    }

    if (kIsWeb) {
      return Image.network(
        controller.selectedImage.value!.path,
        width: double.infinity,
        height: 287,
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        File(controller.selectedImage.value!.path),
        width: double.infinity,
        height: 287,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple[900]));
  }

  Widget _buildRadioTile(String title, String groupValue, void Function(String?) onChanged) {
    return RadioListTile<String>(
      title: Text(title),
      value: title,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Colors.purple[900],
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildRadioTileWithIcon(String title, IconData icon, Color iconColor, String groupValue, void Function(String?) onChanged) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(icon, color: iconColor),
          SizedBox(width: 8),
          Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
        ],
      ),
      value: title,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Colors.purple[900],
      contentPadding: EdgeInsets.zero,
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
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: "₹ ",
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

  Widget _buildQuantityInput(String label, TextEditingController controller) {
    return _buildTextField(label, controller);
  }

  Widget _buildDropdownField(String label, RxString selectedValue, List<String> items) {
    // Remove duplicates and reset selectedValue if invalid
    final uniqueItems = items.toSet().toList();

    if (!uniqueItems.contains(selectedValue.value)) {
      selectedValue.value = "";
    }

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
        items: uniqueItems.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            selectedValue.value = value;
          }
        },
      ),
    ));
  }
}
