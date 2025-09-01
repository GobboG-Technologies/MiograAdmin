import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:miogra_admin/Models/admin_model.dart';

class AdminControllerpage extends GetxController {
  /// All admins from Firestore
  var admin = <AdminModel>[].obs;

  /// Filtered & sorted list for UI
  var filteredAdmins = <AdminModel>[].obs;

  /// Search query
  var searchQuery = ''.obs;

  /// Document upload states
  var aadharUploaded = false.obs;
  var passbookUploaded = false.obs;
  var uploadedDocuments = <String, bool>{}.obs;

  /// Text controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController accountnameController = TextEditingController();
  TextEditingController accountnumberController = TextEditingController();
  TextEditingController ifscController = TextEditingController();

  /// Profile image
  var profileImage = Rxn<Uint8List>();

  /// PDFs
  Rx<Uint8List?> aadharPdf = Rx<Uint8List?>(null);
  Rx<Uint8List?> passbookPdf = Rx<Uint8List?>(null);

  // =====================
  // PICK PROFILE IMAGE
  // =====================
  Future<void> pickProfileImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      profileImage.value = Uint8List.fromList(result.files.first.bytes!);
    }
  }

  // =====================
  // UPLOAD DOCUMENT
  // =====================
  Future<void> uploadDocument(String documentType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      uploadedDocuments[documentType] = true;
      uploadedDocuments.refresh();
    }
  }

  void uploadAadhar(Uint8List fileData) {
    aadharPdf.value = fileData;
  }

  void uploadPassbook(Uint8List fileData) {
    passbookPdf.value = fileData;
  }

  // =====================
  // FETCH ADMINS FROM FIRESTORE
  // =====================
  Future<void> fetchAdmins() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('admins').get();

      admin.clear();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        admin.add(
          AdminModel(
            name: data['name'] ?? '',
            email: data['email'] ?? '',
            phone: data['contact'] ?? '',
            image: data['profileImageUrl'] ?? '',
            id: doc.id,
            location: data['zone'] ?? '',
            accountName: data['accountName'] ?? '',
            accountNumber: data['accountNumber'] ?? '',
            ifsc: data['ifscCode'] ?? '',
          ),
        );
      }

      updateFilteredAdmins(); // initialize filtered list

      print("✅ Admins fetched: ${admin.length}");
    } catch (e) {
      print("❌ Error fetching admins: $e");
    }
  }

  // =====================
  // UPDATE FILTERED ADMINS
  // =====================
  void updateFilteredAdmins() {
    if (searchQuery.isEmpty) {
      filteredAdmins.assignAll(admin);
    } else {
      String query = searchQuery.value.toLowerCase();

      List<AdminModel> matched = [];
      List<AdminModel> others = [];

      for (var a in admin) {
        bool isMatch = a.name.toLowerCase().contains(query) ||
            a.location.toLowerCase().contains(query);

        if (isMatch) {
          matched.add(a);
        } else {
          others.add(a);
        }
      }

      filteredAdmins.assignAll([...matched, ...others]);
    }
  }

  // =====================
  // INIT
  // =====================
  @override
  void onInit() {
    super.onInit();
    fetchAdmins();
    searchQuery.listen((_) => updateFilteredAdmins()); // reactively update list
  }
}
