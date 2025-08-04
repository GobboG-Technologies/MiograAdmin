import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:miogra_admin/Models/admin_model.dart';

import '../Models/CustomerModel.dart';
import '../Models/customerHistoryModel.dart';

class AdminControllerpage extends GetxController{
  var admin = <AdminModel>[].obs;

  var aadharUploaded = false.obs;
  var passbookUploaded = false.obs;
  var uploadedDocuments = <String, bool>{}.obs;
  //var profileImage = Rxn<File>();
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController accountnameController = TextEditingController();
  TextEditingController accountnumberController = TextEditingController();
  TextEditingController ifscController = TextEditingController();

  // Upload Document
  Future<void> uploadDocument(String documentType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      uploadedDocuments[documentType] = true; // Mark as uploaded
      uploadedDocuments.refresh(); // Update UI
    }
  }
  // Upload Profile Picture
  var profileImage = Rxn<Uint8List>(); // Reactive Uint8List

  Future<void> pickProfileImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // Ensures data is available
    );

    if (result != null && result.files.first.bytes != null) {
      // ✅ Fix: Convert Uint8List properly
      profileImage.value = Uint8List.fromList(result.files.first.bytes!);
    }
  }

  // Uploaded PDFs (null means not uploaded)
  Rx<Uint8List?> aadharPdf = Rx<Uint8List?>(null);
  Rx<Uint8List?> passbookPdf = Rx<Uint8List?>(null);

  // Method to upload PDF
  void uploadAadhar(Uint8List fileData) {
    aadharPdf.value = fileData;
  }

  void uploadPassbook(Uint8List fileData) {
    passbookPdf.value = fileData;
  }


  @override
  void onInit() {
    super.onInit();
    loadData();
  }


  void loadData() {
    admin.addAll( [
      AdminModel(
        name: 'Abhilash',
        email: 'abc@gmail.com',
        phone: '9496792155',
        image: "assets/images/img6.png",
        id: "AID98765432101",
        location: 'Madurai',
        accountName: 'Abhilash',
        accountNumber: '1234567890',
        ifsc: 'SBIMH0123456789',

      ),
      AdminModel(
        name: 'Abhila',
        email: 'abc@gmail.com',
        phone: '9496792155',
        image: "assets/images/img6.png",
        id: "AID98765432101",
        location: 'Madurai',
        accountName: 'Abhilash',
        accountNumber: '1234567890',
        ifsc: 'SBIMH0123456789',

      ),
      AdminModel(
        name: 'Abhilas',
        email: 'abc@gmail.com',
        phone: '9496792155',
        image: "assets/images/img1.png",
        id: "AID98765432101",
        location: 'Madurai',
        accountName: 'Abhilash',
        accountNumber: '1234567890',
        ifsc: 'SBIMH0123456789',

      ),
      AdminModel(
        name: 'Abhi',
        email: 'abc@gmail.com',
        phone: '9496792155',
        image: "assets/images/img1.png",
        id: "AID98765432101",
        location: 'Madurai',
        accountName: 'Abhilash',
        accountNumber: '1234567890',
        ifsc: 'SBIMH0123456789',

      ),
      AdminModel(
        name: 'Abhilash',
        email: 'abc@gmail.com',
        phone: '9496792155',
        image: "assets/images/img5.png",
        id: "AID98765432101",
        location: 'Madurai',
        accountName: 'Abhilash',
        accountNumber: '1234567890',
        ifsc: 'SBIMH0123456789',

      ),
      AdminModel(
        name: 'Abhilash',
        email: 'abc@gmail.com',
        phone: '9496792155',
        image: "assets/images/img5.png",
        id: "AID98765432101",
        location: 'Madurai',
        accountName: 'Abhilash',
        accountNumber: '1234567890',
        ifsc: 'SBIMH0123456789',

      ),
      AdminModel(
        name: 'Abhilash',
        email: 'abc@gmail.com',
        phone: '9496792155',
        image: "assets/images/img5.png",
        id: "AID98765432101",
        location: 'Madurai',
        accountName: 'Abhilash',
        accountNumber: '1234567890',
        ifsc: 'SBIMH0123456789',

      ),
      AdminModel(
        name: 'Abhilash',
        email: 'abc@gmail.com',
        phone: '9496792155',
        image: "assets/images/img5.png",
        id: "AID98765432101",
        location: 'Madurai',
        accountName: 'Abhilash',
        accountNumber: '1234567890',
        ifsc: 'SBIMH0123456789',

      ),
      AdminModel(
        name: 'Abhilash',
        email: 'abc@gmail.com',
        phone: '9496792155',
        image: "assets/images/img5.png",
        id: "AID98765432101",
        location: 'Madurai',
        accountName: 'Abhilash',
        accountNumber: '1234567890',
        ifsc: 'SBIMH0123456789',

      ),
      AdminModel(
        name: 'Abhilash',
        email: 'abc@gmail.com',
        phone: '9496792155',
        image: "assets/images/img5.png",
        id: "AID98765432101",
        location: 'Madurai',
        accountName: 'Abhilash',
        accountNumber: '1234567890',
        ifsc: 'SBIMH0123456789',

      ),
      AdminModel(
        name: 'Abhilash',
        email: 'abc@gmail.com',
        phone: '9496792155',
        image: "assets/images/img5.png",
        id: "AID98765432101",
        location: 'Madurai',
        accountName: 'Abhilash',
        accountNumber: '1234567890',
        ifsc: 'SBIMH0123456789',

      ),
      AdminModel(
        name: 'Abhilash',
        email: 'abc@gmail.com',
        phone: '9496792155',
        image: "assets/images/img5.png",
        id: "AID98765432101",
        location: 'Madurai',
        accountName: 'Abhilash',
        accountNumber: '1234567890',
        ifsc: 'SBIMH0123456789',

      ),
      AdminModel(
        name: 'Abhilash',
        email: 'abc@gmail.com',
        phone: '9496792155',
        image: "assets/images/img5.png",
        id: "AID98765432101",
        location: 'Madurai',
        accountName: 'Abhilash',
        accountNumber: '1234567890',
        ifsc: 'SBIMH0123456789',

      ),
    ]);



  }
}