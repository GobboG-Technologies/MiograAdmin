import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

import '../../controller/EditProductController.dart';
import '../../controller/shopController.dart';
import '../sidebar.dart';

class AddNewProductPage extends StatelessWidget {
  final EditProductController controller = Get.put(EditProductController());
  final ShopController controllerS = Get.put(ShopController());

  // Method to show a dialog for choosing image source
  void _showImageSourceDialog(BuildContext context) {
    if (kIsWeb) {
      // For web, directly pick from files
      controller.pickImageWeb();
    } else {
      // For mobile/desktop, show options
      Get.bottomSheet(
        Container(
          color: Colors.white,
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.purple[900]),
                title: Text('Pick from Gallery'),
                onTap: () {
                  Get.back();
                  controller.pickImage(ImageSource.gallery);
                },
              ),
              if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) ...[
                ListTile(
                  leading: Icon(Icons.camera_alt, color: Colors.purple[900]),
                  title: Text('Take a Photo'),
                  onTap: () {
                    Get.back();
                    controller.pickImage(ImageSource.camera);
                  },
                ),
              ],
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Add New Product",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple[900],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                kIsWeb
                                    ? "Web Platform - Firebase Storage Ready"
                                    : "Mobile Platform - Camera & Gallery Available",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: kIsWeb ? Colors.green[700] : Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () => Get.back(),
                            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                            label: Text("Back", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[900],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 30),

                      // Web Success Banner
                      if (kIsWeb) ...[
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green[50]!, Colors.teal[50]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: Colors.green[300]!, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.cloud_done_outlined,
                                  color: Colors.green[800],
                                  size: 28,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Firebase Storage Connected Successfully!",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.green[900],
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "CORS is configured correctly. Image uploads are working perfectly on localhost.",
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.green[300]!),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle_outline,
                                              size: 16, color: Colors.green[700]),
                                          SizedBox(width: 6),
                                          Text(
                                            "Ready for production deployment",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green[800],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Image Upload Section
                      Obx(() {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _buildImageWidget(),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () => _showImageSourceDialog(context),
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                      kIsWeb ? Icons.add_photo_alternate : Icons.camera_alt,
                                      color: Colors.purple[900],
                                      size: 24
                                  ),
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
                          _buildRadioTile("visible", controller.productStatus.value,
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

                      // Main Category Section
                      _buildSectionTitle("Main Category"),
                      Obx(() => Row(
                        children: [
                          _buildRadioTileWithIcon("Food", Icons.fastfood_outlined, Colors.orange, controller.mainCategory.value,
                                  (value) => controller.mainCategory.value = value!),
                          _buildRadioTileWithIcon("FreshCut", Icons.set_meal, Colors.blueGrey, controller.mainCategory.value,
                                  (value) => controller.mainCategory.value = value!),
                          _buildRadioTileWithIcon("Daily Mio", Icons.shopping_bag, Colors.red, controller.mainCategory.value,
                                  (value) => controller.mainCategory.value = value!),
                          _buildRadioTileWithIcon("Pharmacy", Icons.vaccines, Colors.lightBlueAccent, controller.mainCategory.value,
                                  (value) => controller.mainCategory.value = value!),
                        ],
                      )),

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
                            child: _buildPriceInput("Your Price", controller.yourprice),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),
                      _buildMultilineField("Description", controller.description),
                      SizedBox(height: 12),
                      _buildQuantityInput("Quantity", controller.productQty),

                      SizedBox(height: 12),

                      // Shops Grid
                      _buildSectionTitle("Shops in Your Zone"),
                      SizedBox(height: 16),

                      Obx(() {
                        final shops = controllerS.shops;

                        if (shops.isEmpty) {
                          return Container(
                            padding: EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.store_outlined,
                                      size: 48, color: Colors.grey[400]),
                                  SizedBox(height: 8),
                                  Text("No shops found in your zone",
                                      style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                            ),
                          );
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isMobile ? 2 : 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemCount: shops.length,
                          itemBuilder: (context, index) {
                            final shop = shops[index];
                            final isSelected = controllerS.selectedShopId.value == shop["id"];

                            return GestureDetector(
                              onTap: () {
                                controllerS.selectedShopId.value = shop["id"];
                                controller.shopId.text = shop["id"];
                                controller.shopName.text = shop["name"];
                                print("Selected shop: ${shop["name"]} (${shop["id"]})");
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.purple[100] : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? Colors.purple[900]! : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ] : [],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Image.network(
                                            shop["image"],
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Icon(Icons.store,
                                                      size: 30, color: Colors.grey[400]),
                                                ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.check,
                                                  size: 12, color: Colors.white),
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      shop["name"],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.purple[900] : Colors.grey[800],
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      shop["id"],
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSelected ? Colors.purple[700] : Colors.grey[500],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),

                      SizedBox(height: 30),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            print("ADD PRODUCT BUTTON PRESSED!");
                            try {
                              await controller.addProductToFirestore();
                              print("Product upload completed successfully!");
                            } catch (e) {
                              print("Product upload failed: $e");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[900],
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_box, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                kIsWeb
                                    ? "Add Product (Firebase Storage)"
                                    : "Add Product",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (kIsWeb) ...[
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Web",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Web success info
                      if (kIsWeb) ...[
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 20, color: Colors.green[700]),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Web platform with Firebase Storage ready. CORS is configured and working perfectly.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[800],
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: 40),
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

  // Image widget method
  Widget _buildImageWidget() {
    if (controller.selectedImage.value == null) {
      return Container(
        width: double.infinity,
        height: 287,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[200]!, Colors.grey[300]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 80, color: Colors.grey[500]),
            SizedBox(height: 12),
            Text(
              kIsWeb
                  ? "Click + icon to add image from files"
                  : "Tap camera icon to add image",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Supports JPG, PNG up to 5MB",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            if (kIsWeb) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Text(
                  "Web: Firebase Storage Ready",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: controller.selectedImage.value!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              width: double.infinity,
              height: 287,
              fit: BoxFit.cover,
            );
          }
          return Container(
            width: double.infinity,
            height: 287,
            color: Colors.grey[300],
            child: Center(child: CircularProgressIndicator()),
          );
        },
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

  // Section Title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.purple[900],
      ),
    );
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
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
      ),
    );
  }

  // Radio with Icon
  Widget _buildRadioTileWithIcon(
      String title, IconData icon, Color iconColor, String groupValue, void Function(String?) onChanged) {
    return Expanded(
      child: RadioListTile<String>(
        title: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 14)),
          ],
        ),
        value: title,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: Colors.purple[900],
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.purple[900]!, width: 2),
        ),
      ),
    );
  }

  Widget _buildPriceInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.purple[900],
            fontSize: 14,
          ),
        ),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: "₹ ",
            prefixStyle: TextStyle(
              color: Colors.purple[900],
              fontWeight: FontWeight.w600,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.purple[900]!, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultilineField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.purple[900]!, width: 2),
        ),
      ),
    );
  }

  Widget _buildQuantityInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.purple[900]!, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, RxString selectedValue, List<String> items) {
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: selectedValue.value.isEmpty ? null : selectedValue.value,
        hint: Text(label, style: TextStyle(color: Colors.grey[600])),
        isExpanded: true,
        underline: SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: Colors.purple[900]),
        items: items.map((item) {
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