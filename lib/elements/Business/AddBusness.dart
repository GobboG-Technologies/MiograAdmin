// lib/pages/add_new_business.dart

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controller/addShopController.dart';

// Make sure the path to your controller is correct


// --- Constants (can be in their own file or here) ---
const Color kPrimaryColor = Color(0xFF583081);
const Color kPrimaryColorTransparent = Color(0x0F583081);
const Color kPrimaryColorMedium = Color(0xCC583081);
const Color kTextColor = Color(0xFF818181);
const Color kAccentColor = Color(0xFFFF8800);
const Color kSuccessColor = Color(0xFF08C270);
const double kVerticalPadding = 16.0;

// ✅ The entire widget is now Stateless
class AddNewBusiness extends StatelessWidget {
  AddNewBusiness({super.key});

  // ✅ Instantiate the controller using GetX. This single line gives the UI access to all controller variables and methods.
  final AddShopController controller = Get.put(AddShopController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add New Shop', style: TextStyle(color: kPrimaryColor, fontSize: 23, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: LayoutBuilder(
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
                              // --- All widgets are now driven by the controller ---
                              _buildImagePicker(),
                              const SizedBox(height: 24),
                              _buildSectionHeader('Business Details'),
                              const SizedBox(height: kVerticalPadding),
                              // ✅ CONNECTED: TextFields now use controllers from AddShopController
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  _buildTextField(hintText: 'Seller Name', controller: controller.sellerName),
                                  _buildTextField(hintText: 'Business name *', controller: controller.businessName),
                                  _buildTextField(hintText: 'Aadhar Number', controller: controller.aadharNumber),
                                  _buildTextField(hintText: 'PAN Number', controller: controller.panNumber),
                                  _buildTextField(hintText: 'GST', controller: controller.gstNumber),
                                  _buildTextField(hintText: 'Contact *', controller: controller.contact),
                                  _buildTextField(hintText: 'Alternate Contact Number', controller: controller.alternateContact),
                                  _buildTextField(hintText: 'Door Number', controller: controller.doorNumber),
                                  _buildTextField(hintText: 'Street Name', controller: controller.streetName),
                                  _buildTextField(hintText: 'Area', controller: controller.area),
                                  _buildTextField(hintText: 'PIN Number', controller: controller.pinNumber),
                                  _buildTextField(hintText: 'FSSAI', controller: controller.fssai),
                                ],
                              ),
                              const SizedBox(height: kVerticalPadding),
                              Row(
                                children: [
                                  Expanded(child: _buildZoneButton('Customer Zone')),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildZoneButton('Delivery Zone')),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildLocationPicker(),
                              const SizedBox(height: kVerticalPadding),
                              Row(
                                children: [
                                  Expanded(child: _buildTimePickerRow('Shop Open Time', '09:00 AM')),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTimePickerRow('Shop Close Time', '10:00 PM')),
                                ],
                              ),
                              const SizedBox(height: 32),
                              _buildSectionHeader('Bank Details'),
                              const SizedBox(height: kVerticalPadding),
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  _buildTextField(hintText: 'Name as in Bank', controller: controller.bankName),
                                  _buildTextField(hintText: 'Account Number', controller: controller.accountNumber),
                                  _buildTextField(hintText: 'IFSC Code', controller: controller.ifscCode),
                                  _buildTextField(hintText: 'UPI ID', controller: controller.upiId),
                                  _buildTextField(hintText: 'GPay Number', controller: controller.gpayNumber),
                                ],
                              ),
                              const SizedBox(height: 32),
                              _buildSectionHeader('Documents Upload (PDF only)'),
                              const SizedBox(height: 24),
                              // ✅ CONNECTED: PDF buttons now use the controller's logic
                              _buildPdfUploadButton('Aadhar', Icons.picture_as_pdf_outlined),
                              const SizedBox(height: 12),
                              _buildPdfUploadButton('Pan', Icons.picture_as_pdf_outlined),
                              const SizedBox(height: 12),
                              _buildPdfUploadButton('GST File', Icons.picture_as_pdf_outlined),
                              const SizedBox(height: 12),
                              _buildPdfUploadButton('Bank Passbook', Icons.picture_as_pdf_outlined),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // ✅ CONNECTED: Action buttons now use controller's state and methods
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET BUILDER METHODS ---
  // These are helper methods to keep the main build method clean.

  /// Builds the image picker, reacting to changes in the controller's `profileImage`.
  Widget _buildImagePicker() {
    return Obx(() {
      return GestureDetector(
        onTap: () => controller.pickProfileImage(), // Calls controller method
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: controller.profileImage.value == null
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
              Container(
                width: double.infinity,
                height: double.infinity,
                child: ClipRRect(borderRadius: BorderRadius.circular(10), child: _buildImageWidget(controller.profileImage.value!)),
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

  /// Renders the selected image correctly for web or mobile.
  Widget _buildImageWidget(XFile imageFile) {
    if (kIsWeb) {
      return Image.network(imageFile.path, fit: BoxFit.cover, width: double.infinity, height: double.infinity,
          errorBuilder: (context, error, stackTrace) => const Center(child: Text("Error loading image", style: TextStyle(color: Colors.red))));
    } else {
      return Image.file(File(imageFile.path), fit: BoxFit.cover, width: double.infinity, height: double.infinity,
          errorBuilder: (context, error, stackTrace) => const Center(child: Text("Error loading image", style: TextStyle(color: Colors.red))));
    }
  }

  /// Builds a PDF upload button, reacting to changes in the controller's `uploadedDocs` map.
  Widget _buildPdfUploadButton(String label, IconData icon) {
    return Obx(() {
      final docFile = controller.uploadedDocs[label];
      final isUploaded = docFile != null;

      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => controller.pickPdfFile(label), // Calls controller method
              icon: isUploaded ? const Icon(Icons.check_circle, color: kSuccessColor) : Icon(icon, color: kPrimaryColorMedium),
              label: Row(
                children: [
                  Text(label, style: TextStyle(color: isUploaded ? kSuccessColor : kPrimaryColorMedium, fontSize: 15, fontWeight: FontWeight.w500)),
                  if (isUploaded) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text("(${docFile.name})", style: const TextStyle(color: kTextColor, fontSize: 12, fontWeight: FontWeight.w400), overflow: TextOverflow.ellipsis),
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
              onPressed: () => controller.deletePdfFile(label), // Calls controller method
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

  /// Builds a text field that is connected to a specific `TextEditingController`.
  Widget _buildTextField({required String hintText, required TextEditingController controller}) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller, // Connection point
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

  /// Builds the final action buttons, reacting to the controller's `isLoading` state.
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100.0),
      child: Obx(() { // This makes the buttons rebuild when isLoading changes
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: controller.isLoading.value ? null : () => Get.back(), // Disable when loading
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
                  onPressed: controller.isLoading.value ? null : () => controller.addShop(), // Calls controller method
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColorMedium, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: controller.isLoading.value
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('+ Add', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // --- Placeholder Widgets (Functionality can be added later) ---

  Widget _buildZoneButton(String label) {
    return OutlinedButton(onPressed: () {}, /* TODO: Implement Zone selection */ style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), side: const BorderSide(color: kPrimaryColorMedium), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Align(alignment: Alignment.centerLeft, child: Text(label, style: const TextStyle(color: kTextColor, fontSize: 15, fontFamily: 'Poppins', fontWeight: FontWeight.w400))));
  }

  Widget _buildLocationPicker() {
    return OutlinedButton.icon(onPressed: () {}, /* TODO: Implement Location picker */ icon: const Icon(Icons.location_on, color: kPrimaryColor), label: const Text('Pick Exact Location', style: TextStyle(color: kPrimaryColor, fontSize: 15, fontWeight: FontWeight.w500)), style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), side: const BorderSide(color: kPrimaryColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
  }

  Widget _buildTimePickerRow(String label, String time) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: kTextColor, fontSize: 15, fontWeight: FontWeight.w500)),
      TextButton(onPressed: () {}, /* TODO: Implement Time picker */ style: TextButton.styleFrom(backgroundColor: kPrimaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)), child: Text(time, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500))),
    ]);
  }
}