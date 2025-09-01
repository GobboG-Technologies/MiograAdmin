import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// Make sure the path to your controller is correct
import '../../controller/addShopController.dart';


// --- Constants ---
const Color kPrimaryColor = Color(0xFF583081);
const Color kPrimaryColorTransparent = Color(0x0F583081);
const Color kPrimaryColorMedium = Color(0xCC583081);
const Color kTextColor = Color(0xFF818181);
const Color kAccentColor = Color(0xFFFF8800);
const Color kSuccessColor = Color(0xFF08C270);
const double kVerticalPadding = 16.0;


class AddNewBusiness extends StatefulWidget {
  final String? businessId; // Can be null for "add new" mode

  AddNewBusiness({super.key, this.businessId});

  @override
  State<AddNewBusiness> createState() => _AddNewBusinessState();
}

class _AddNewBusinessState extends State<AddNewBusiness> {
  // Instantiate the controller using GetX.
  late final AddShopController controller;

  @override
  void initState() {
    super.initState();
    // Get a fresh instance of the controller
    controller = Get.put(AddShopController());

    // If a businessId is provided, initialize the controller for edit mode
    if (widget.businessId != null) {
      controller.initForEdit(widget.businessId!);
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed
    Get.delete<AddShopController>();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // ✅ DYNAMIC APP BAR TITLE
        title: Obx(() => Text(
            controller.isEditMode.value ? 'Edit Shop' : 'Add New Shop',
            style: const TextStyle(color: kPrimaryColor, fontSize: 23, fontWeight: FontWeight.w500)
        )),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryColor),
          onPressed: () {
            controller.clearAllFields();
            Get.back();
          },
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.isEditMode.value) {
          return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
        }
        return GetBuilder<AddShopController>(
          builder: (controller) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1300),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: Scrollbar(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildImagePicker(),
                                    const SizedBox(height: 24),
                                    _buildSectionHeader('Business Details'),
                                    const SizedBox(height: kVerticalPadding),
                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 16,
                                      children: [
                                        _buildTextField(hintText: 'Owner Name', controller: controller.nameController),
                                        _buildTextField(hintText: 'Business name *', controller: controller.BusinessNameController),
                                        _buildTextField(hintText: 'Aadhar Number', controller: controller.aadharController),
                                        _buildTextField(hintText: 'PAN Number', controller: controller.panController),
                                        _buildTextField(hintText: 'GST', controller: controller.GSTController),
                                        _buildTextField(hintText: 'FSSAI', controller: controller.fssaiController),
                                        _buildTextField(hintText: 'Contact *', controller: controller.contactController),
                                        _buildTextField(hintText: 'Alternate Contact Number', controller: controller.emergencyContact2),
                                        _buildTextField(hintText: 'Door Number', controller: controller.doorController),
                                        _buildTextField(hintText: 'Street Name', controller: controller.streetController),
                                        _buildTextField(hintText: 'Area', controller: controller.areaController),
                                        _buildTextField(hintText: 'PIN Number', controller: controller.pinController),
                                      ],
                                    ),
                                    const SizedBox(height: kVerticalPadding),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: _buildZoneDropdown(
                                            hintText: 'Customer Zone *',
                                            selectedValue: controller.customerZone,
                                            onChanged: (value) {
                                              if (value != null) controller.updateCustomerZone(value);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildZoneDropdown(
                                            hintText: 'Delivery Zone *',
                                            selectedValue: controller.deliveryZone,
                                            onChanged: (value) {
                                              if (value != null) controller.updateDeliveryZone(value);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _buildLocationPicker(),
                                    const SizedBox(height: kVerticalPadding),
                                    Row(
                                      children: [
                                        Expanded(child: _buildTimePicker(context, 'Shop Open Time', controller.openTime, true)),
                                        const SizedBox(width: 16),
                                        Expanded(child: _buildTimePicker(context, 'Shop Close Time', controller.closeTime, false)),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                    _buildSectionHeader('Bank Details'),
                                    const SizedBox(height: kVerticalPadding),
                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 16,
                                      children: [
                                        _buildTextField(hintText: 'Name as in Bank', controller: controller.bankNameController),
                                        _buildTextField(hintText: 'Account Number', controller: controller.accountNumberController),
                                        _buildTextField(hintText: 'IFSC Code', controller: controller.ifscController),
                                        _buildTextField(hintText: 'UPI ID', controller: controller.upiIdController),
                                        _buildTextField(hintText: 'GPay Number', controller: controller.gpay),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildSectionHeader('Categories'),
                                    const SizedBox(height: 16),
                                    _buildCategorySelector(),
                                    const SizedBox(height: 32),
                                    _buildSectionHeader('Documents Upload (PDF only)'),
                                    const SizedBox(height: 24),
                                    ...controller.docTypes.map((docType) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0),
                                        child: _buildPdfUploadButton(docType, Icons.picture_as_pdf_outlined),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }

  // --- WIDGET BUILDER METHODS ---

  Widget _buildImagePicker() {
    return Obx(() {
      return GestureDetector(
        onTap: () => controller.pickProfileImage(),
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          // ✅ DYNAMIC IMAGE DISPLAY LOGIC
          child: (controller.profileImage.value == null && (controller.networkImage.value == null || controller.networkImage.value!.isEmpty))
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_a_photo, color: kPrimaryColor, size: 40),
              const SizedBox(height: 8),
              Text("Tap to add Profile Image *", style: TextStyle(color: Colors.grey[600]))
            ],
          )
              : Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: controller.profileImage.value != null
                      ? _buildImageWidget(controller.profileImage.value!)
                      : Image.network(
                    controller.networkImage.value!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  radius: 20,
                  child: const Icon(Icons.camera_alt, color: kPrimaryColor),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCategorySelector() {
    return Obx(() {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: controller.allCategories.map((category) {
          final isSelected = controller.selectedCategories.contains(category);
          return ChoiceChip(
            label: Text(category,
                style: TextStyle(
                  color: isSelected ? Colors.white : kPrimaryColor,
                  fontWeight: FontWeight.w500,
                )),
            selected: isSelected,
            selectedColor: kPrimaryColor,
            backgroundColor: kPrimaryColorTransparent,
            onSelected: (_) => controller.toggleCategory(category),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected ? kPrimaryColor : kPrimaryColorMedium,
                width: 1.2,
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildImageWidget(XFile imageFile) {
    if (kIsWeb) {
      return Image.network(imageFile.path, fit: BoxFit.cover, width: double.infinity, height: double.infinity,
          errorBuilder: (context, error, stackTrace) => const Center(child: Text("Error loading image", style: TextStyle(color: Colors.red))));
    } else {
      return Image.file(File(imageFile.path), fit: BoxFit.cover, width: double.infinity, height: double.infinity,
          errorBuilder: (context, error, stackTrace) => const Center(child: Text("Error loading image", style: TextStyle(color: Colors.red))));
    }
  }

  Widget _buildPdfUploadButton(String label, IconData icon) {
    return Obx(() {
      final docFile = controller.uploadedDocs[label];
      final existingFileUrl = controller.existingDocs[label];
      final isUploaded = docFile != null || existingFileUrl != null;
      final displayName = docFile?.name ?? (existingFileUrl != null ? "$label.pdf" : "");

      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => controller.pickPdfFile(label),
              icon: isUploaded ? const Icon(Icons.check_circle, color: kSuccessColor) : Icon(icon, color: kPrimaryColorMedium),
              label: Row(
                children: [
                  Text(label, style: TextStyle(color: isUploaded ? kSuccessColor : kPrimaryColorMedium, fontSize: 15, fontWeight: FontWeight.w500)),
                  if (isUploaded) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text("($displayName)", style: const TextStyle(color: kTextColor, fontSize: 12, fontWeight: FontWeight.w400), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ],
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: isUploaded ? kSuccessColor : kPrimaryColorMedium, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          if (isUploaded) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => controller.removePdfFile(label),
              tooltip: "Remove $label",
            ),
          ],
        ],
      );
    });
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(color: kPrimaryColor, fontSize: 20, fontFamily: 'Poppins', fontWeight: FontWeight.w500));
  }

  Widget _buildTextField({required String hintText, required TextEditingController controller}) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: kTextColor, fontSize: 15, fontFamily: 'Poppins', fontWeight: FontWeight.w400),
          filled: true,
          fillColor: kPrimaryColorTransparent,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100.0),
      child: Obx(() {
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: controller.isLoading.value ? null : () => Get.back(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(width: 2, color: kAccentColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Close', style: TextStyle(color: kAccentColor, fontSize: 17, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  // ✅ DYNAMIC ACTION
                  onPressed: controller.isLoading.value ? null : () => controller.saveOrUpdateShop(),
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColorMedium, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: controller.isLoading.value
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  // ✅ DYNAMIC BUTTON TEXT
                      : Text(controller.isEditMode.value ? 'Update' : '+ Add', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildZoneDropdown({
    required String hintText,
    required RxString selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Obx(() {
      if (controller.zoneNames.isEmpty && controller.isLoading.value) {
        return const SizedBox(height: 50);
      }
      if (controller.zoneNames.isEmpty) {
        return const Text("No zones available.");
      }

      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: kTextColor, fontSize: 15, fontFamily: 'Poppins', fontWeight: FontWeight.w400),
          filled: true,
          fillColor: kPrimaryColorTransparent,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        value: selectedValue.value.isEmpty ? null : selectedValue.value,
        isExpanded: true,
        items: controller.zoneNames.map((zoneName) {
          return DropdownMenuItem<String>(
            value: zoneName,
            child: Text(zoneName),
          );
        }).toList(),
        onChanged: onChanged,
      );
    });
  }

  Widget _buildLocationPicker() {
    return OutlinedButton.icon(
        onPressed: () {
          print("Location picker tapped!");
        },
        icon: const Icon(Icons.location_on, color: kPrimaryColor),
        label: Text(
          controller.selectedPlaceName ?? 'Pick Exact Location *',
          style: const TextStyle(color: kPrimaryColor, fontSize: 15, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            side: const BorderSide(color: kPrimaryColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
        )
    );
  }

  Widget _buildTimePicker(BuildContext context, String label, Rx<TimeOfDay> timeValue, bool isOpenTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: kTextColor, fontSize: 15, fontWeight: FontWeight.w500)),
        Obx(() => TextButton(
          onPressed: () => controller.pickTime(isOpenTime, context),
          style: TextButton.styleFrom(backgroundColor: kPrimaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
          child: Text(
            controller.formatTime(timeValue.value),
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        )),
      ],
    );
  }
}