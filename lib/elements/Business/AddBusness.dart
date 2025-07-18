import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // Add this for kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

const Color kPrimaryColor = Color(0xFF583081);
const Color kPrimaryColorTransparent = Color(0x0F583081);
const Color kPrimaryColorMedium = Color(0xCC583081);
const Color kTextColor = Color(0xFF818181);
const Color kAccentColor = Color(0xFFFF8800);
const Color kSuccessColor = Color(0xFF08C270);
const double kVerticalPadding = 16.0;

class AddNewBusiness extends StatefulWidget {
  const AddNewBusiness({super.key});

  @override
  State<AddNewBusiness> createState() => AddNewBusinessDesktopState();
}

class AddNewBusinessDesktopState extends State<AddNewBusiness> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final Map<String, bool> _uploadedDocs = {
    'Aadhar': false,
    'Pan': false,
    'GST File': false,
    'Profile': false,
    'Bank Passbook': false,
  };

  final Map<String, String?> _uploadedDocPaths = {
    'Aadhar': null,
    'Pan': null,
    'GST File': null,
    'Profile': null,
    'Bank Passbook': null,
  };

  // ✅ Add this for storing file data on web
  final Map<String, Uint8List?> _uploadedDocBytes = {
    'Aadhar': null,
    'Pan': null,
    'GST File': null,
    'Profile': null,
    'Bank Passbook': null,
  };

  Future<void> _pickImageFromFiles() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print("Picked image path: ${pickedFile.path}");
        setState(() {
          _imageFile = pickedFile;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image selected successfully"),
            backgroundColor: kSuccessColor,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print("Image picker error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error picking image: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickPdfFile(String docType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        print("Picked $docType file: ${file.name}");

        if (kIsWeb) {
          // ✅ For web, store bytes
          final bytes = file.bytes;
          if (bytes != null) {
            setState(() {
              _uploadedDocs[docType] = true;
              _uploadedDocPaths[docType] = file.name; // Store filename for display
              _uploadedDocBytes[docType] = bytes; // Store bytes for upload
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$docType uploaded successfully"),
                backgroundColor: kSuccessColor,
              ),
            );
          }
        } else {
          // ✅ For mobile, store path
          final filePath = file.path;
          if (filePath != null) {
            setState(() {
              _uploadedDocs[docType] = true;
              _uploadedDocPaths[docType] = filePath;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$docType uploaded successfully"),
                backgroundColor: kSuccessColor,
              ),
            );
          }
        }
      }
    } catch (e) {
      print("PDF file picker error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error picking $docType: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deletePdfFile(String docType) {
    setState(() {
      _uploadedDocs[docType] = false;
      _uploadedDocPaths[docType] = null;
      _uploadedDocBytes[docType] = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$docType removed"),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add New Shop',
          style: TextStyle(
            color: kPrimaryColor,
            fontSize: 23,
            fontWeight: FontWeight.w500,
          ),
        ),
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
                          padding: EdgeInsets.zero,
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
                                  _buildTextField(hintText: 'Seller Name'),
                                  _buildTextField(hintText: 'Business name'),
                                  _buildTextField(hintText: 'Aadhar Number'),
                                  _buildTextField(hintText: 'PAN Number'),
                                  _buildTextField(hintText: 'GST'),
                                  _buildTextField(hintText: 'Contact'),
                                  _buildTextField(hintText: 'Alternate Contact Number'),
                                  _buildTextField(hintText: 'Door Number'),
                                  _buildTextField(hintText: 'Street Name'),
                                  _buildTextField(hintText: 'Area'),
                                  _buildTextField(hintText: 'PIN Number'),
                                  _buildTextField(hintText: 'FSSAI'),
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
                                  _buildTextField(hintText: 'Name'),
                                  _buildTextField(hintText: 'Account Number'),
                                  _buildTextField(hintText: 'IFSC Code'),
                                  _buildTextField(hintText: 'UPI ID'),
                                  _buildTextField(hintText: 'GPay Number'),
                                ],
                              ),
                              const SizedBox(height: 32),
                              _buildSectionHeader('Documents Upload'),
                              const SizedBox(height: 24),
                              _buildPdfUploadButton('Aadhar', Icons.picture_as_pdf_outlined,),
                              const SizedBox(height: 12),
                              _buildPdfUploadButton('Pan', Icons.picture_as_pdf_outlined),
                              const SizedBox(height: 12),
                              _buildPdfUploadButton('GST File', Icons.picture_as_pdf_outlined),
                              const SizedBox(height: 12),
                              _buildPdfUploadButton('Profile', Icons.picture_as_pdf_outlined),
                              const SizedBox(height: 12),
                              _buildPdfUploadButton('Bank Passbook', Icons.picture_as_pdf_outlined),
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
      ),
    );
  }

  // ✅ FIXED: Web-compatible image picker
  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImageFromFiles,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: _imageFile == null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo, color: kPrimaryColor, size: 40),
            const SizedBox(height: 8),
            Text("Tap to add image", style: TextStyle(color: Colors.grey[600]))
          ],
        )
            : Stack(
          children: [
            // ✅ Web-compatible image display
            Container(
              width: double.infinity,
              height: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildImageWidget(),
              ),
            ),
            // Camera icon overlay
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
  }

  // ✅ Platform-specific image widget
  Widget _buildImageWidget() {
    if (_imageFile == null) {
      return Container();
    }

    if (kIsWeb) {
      // ✅ For web, use Image.network with blob URL
      return Image.network(
        _imageFile!.path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryColor),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print("Web image error: $error");
          return Container(
            color: Colors.grey[300],
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 40),
                Text("Error loading image", style: TextStyle(color: Colors.red)),
              ],
            ),
          );
        },
      );
    } else {
      // ✅ For mobile, use Image.file
      return Image.file(
        File(_imageFile!.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          print("Mobile image error: $error");
          return Container(
            color: Colors.grey[300],
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 40),
                Text("Error loading image", style: TextStyle(color: Colors.red)),
              ],
            ),
          );
        },
      );
    }
  }

  // ✅ IMPROVED: PDF upload button with better feedback
  Widget _buildPdfUploadButton(String label, IconData icon) {
    final isUploaded = _uploadedDocs[label] == true;
    final hasFile = _uploadedDocPaths[label] != null;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickPdfFile(label),
            icon: isUploaded
                ? const Icon(Icons.check_circle, color: kSuccessColor)
                : Icon(icon, color: kPrimaryColorMedium),
            label: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isUploaded ? kSuccessColor : kPrimaryColorMedium,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (hasFile) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "(${_getFileName(_uploadedDocPaths[label]!)})",
                      style: const TextStyle(
                        color: kTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: isUploaded ? kSuccessColor : kPrimaryColorMedium,
                  width: 1
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        if (hasFile) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deletePdfFile(label),
            tooltip: "Remove $label",
          ),
        ],
      ],
    );
  }

  // ✅ Helper method to extract filename
  String _getFileName(String path) {
    if (kIsWeb) {
      // For web, the path might be just the filename
      return path.split('/').last;
    } else {
      // For mobile, extract filename from full path
      return path.split('/').last;
    }
  }

  Widget _buildSectionHeader(String title) {
    return Text(
        title,
        style: const TextStyle(
            color: kPrimaryColor,
            fontSize: 20,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500
        )
    );
  }

  Widget _buildTextField({required String hintText}) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
              color: kTextColor,
              fontSize: 15,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400
          ),
          filled: true,
          fillColor: kPrimaryColorTransparent,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildZoneButton(String label) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        side: const BorderSide(color: kPrimaryColorMedium),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
              label,
              style: const TextStyle(
                  color: kTextColor,
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400
              )
          )
      ),
    );
  }

  Widget _buildLocationPicker() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.location_on, color: kPrimaryColor),
      label: const Text(
          'Pick Exact Location',
          style: TextStyle(
              color: kPrimaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w500
          )
      ),
      style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: kPrimaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
      ),
    );
  }

  Widget _buildTimePickerRow(String label, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
            label,
            style: const TextStyle(
                color: kTextColor,
                fontSize: 15,
                fontWeight: FontWeight.w500
            )
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
          ),
          child: Text(
              time,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500
              )
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100.0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(width: 2, color: kAccentColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: const Text(
                    'Close',
                    style: TextStyle(
                        color: kAccentColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w500
                    )
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColorMedium,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: const Text(
                    '+ Add',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500
                    )
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}