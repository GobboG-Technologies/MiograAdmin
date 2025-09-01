import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';


// A helper class for managing file data for both web and mobile
class DocFile {
  final String name;
  final String? path; // Mobile
  final Uint8List? bytes; // Web

  DocFile({required this.name, this.path, this.bytes});
}


class AddShopController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid uuid = Uuid();

  // Mode management
  var isEditMode = false.obs;
  String? currentShopId;


  // Loading State
  var isLoading = false.obs;

  // Form Controllers - Aligned with Business App
  final nameController = TextEditingController(); // Owner Name
  final BusinessNameController = TextEditingController(); // Shop Name
  final aadharController = TextEditingController();
  final panController = TextEditingController();
  final GSTController = TextEditingController();
  final fssaiController = TextEditingController();
  final contactController = TextEditingController();
  final emergencyContact2 = TextEditingController(); // Alternate Contact

  // Address Controllers
  final doorController = TextEditingController();
  final streetController = TextEditingController();
  final areaController = TextEditingController();
  final pinController = TextEditingController();

  // Bank Details Controllers
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscController = TextEditingController();
  final upiIdController = TextEditingController();
  final gpay = TextEditingController();

  // Zone Management - Aligned with Business App
  var zoneNames = <String>[].obs;
  var availableZoneData = <Map<String, dynamic>>[].obs;
  var customerZone = "".obs;
  var deliveryZone = "".obs;
  Map<String, dynamic>? selectedDeliveryZoneData;


  // Categories - Aligned with Business App
  final List<String> allCategories = ['Fresh Cut', 'Food', 'Daily Mio'];
  var selectedCategories = <String>[].obs;

  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
  }

  // Time Selection
  var openTime = Rx<TimeOfDay>(const TimeOfDay(hour: 9, minute: 0));
  var closeTime = Rx<TimeOfDay>(const TimeOfDay(hour: 22, minute: 0));

  // Location Data
  double? selectedLat;
  double? selectedLng;
  String? selectedPlaceName;

  void setSelectedLocation(double? lat, double? lng, String placeName) {
    selectedLat = lat;
    selectedLng = lng;
    selectedPlaceName = placeName;
    update();
  }

  // File Management
  var profileImage = Rx<XFile?>(null);
  var networkImage = RxnString(); // For displaying existing image in edit mode
  var uploadedDocs = <String, DocFile?>{}.obs;
  var existingDocs = <String, String>{}.obs; // For displaying existing docs
  final List<String> docTypes = ['Aadhar', 'Pan', 'Driving License', 'Bank Passbook'];


  @override
  void onInit() {
    super.onInit();
    fetchZones();
  }

  // ✅ NEW: Initializes the controller for editing an existing shop
  Future<void> initForEdit(String businessId) async {
    isEditMode.value = true;
    currentShopId = businessId;
    await loadShopData(businessId);
  }


  // ✅ NEW: Loads existing data from Firestore into the UI
  Future<void> loadShopData(String businessId) async {
    isLoading.value = true;
    try {
      final doc = await _firestore.collection("Shops").doc(businessId).get();
      if (doc.exists) {
        final data = doc.data()!;

        // Fill text controllers
        BusinessNameController.text = data['name'] ?? '';
        nameController.text = data['ownerName'] ?? '';
        contactController.text = data['contact'] ?? '';
        emergencyContact2.text = data['emergencyContact'] ?? '';
        aadharController.text = data['aadhar'] ?? '';
        panController.text = data['pan'] ?? '';
        GSTController.text = data['GST'] ?? '';
        fssaiController.text = data['fssai'] ?? '';
        bankNameController.text = data['BankName'] ?? '';
        accountNumberController.text = data['accountNumber'] ?? '';
        ifscController.text = data['ifsc'] ?? '';
        upiIdController.text = data['upi'] ?? '';
        gpay.text = data['GpayNumber'] ?? '';

        // Address
        doorController.text = data['DoorNo'] ?? '';
        streetController.text = data['Street'] ?? '';
        areaController.text = data['area'] ?? '';
        // Safely extract PIN from address string
        String fullAddress = data['address'] ?? '';
        if (fullAddress.contains("PIN:")) {
          pinController.text = fullAddress.split("PIN:").last.trim();
        }


        // Zones
        await fetchZones(); // Ensure zones are loaded before setting values
        customerZone.value = data['customerZone'] ?? '';
        deliveryZone.value = data['deliveryZone'] ?? '';


        // Location
        selectedLat = data['location']?['latitude']?.toDouble();
        selectedLng = data['location']?['longitude']?.toDouble();
        selectedPlaceName = data['location']?['placeName'];
        update(); // For GetBuilder

        // Categories
        selectedCategories.assignAll(List<String>.from(data['selectedCategories'] ?? []));

        // Images and Docs
        networkImage.value = data['profileImage'];
        existingDocs.assignAll(Map<String, String>.from(data['documents'] ?? {}));

        // Time Parsing (from '09:00 AM' format)
        openTime.value = _parseTime(data['openTime']) ?? const TimeOfDay(hour: 9, minute: 0);
        closeTime.value = _parseTime(data['closeTime']) ?? const TimeOfDay(hour: 22, minute: 0);

      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load shop data: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> fetchZones() async {
    try {
      final snapshot = await _firestore.collection('zone').get();
      final zones = snapshot.docs.map((doc) {
        return {
          'zone': doc['zoneName'],
          'zonePoints': doc['zonePoints'],
          'zoneId': doc.id,
        };
      }).toList();

      availableZoneData.assignAll(zones);
      zoneNames.assignAll(zones.map((z) => z['zone'].toString()).toList());

    } catch (e) {
      Get.snackbar('Error Fetching Zones', 'Could not retrieve zone list: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Zone Update Methods
  void updateCustomerZone(String value) {
    customerZone.value = value;
  }

  void updateDeliveryZone(String value) {
    deliveryZone.value = value;
    selectedDeliveryZoneData = availableZoneData.firstWhereOrNull(
          (zone) => zone['zone'] == value,
    );
  }

  // Pickers
  Future<void> pickProfileImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      profileImage.value = picked;
      networkImage.value = null; // Clear network image when a new one is picked
    }
  }

  Future<void> pickPdfFile(String docType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['pdf'], withData: kIsWeb,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      uploadedDocs[docType] = DocFile(
        name: file.name,
        path: kIsWeb ? null : file.path,
        bytes: kIsWeb ? file.bytes : null,
      );
      if (existingDocs.containsKey(docType)) {
        existingDocs.remove(docType);
      }
    }
  }

  void removePdfFile(String docType) {
    uploadedDocs.remove(docType);
    existingDocs.remove(docType); // Also remove from existing if user decides to delete
  }

  Future<void> pickTime(bool isOpenTime, BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpenTime ? openTime.value : closeTime.value,
    );
    if (picked != null) {
      if (isOpenTime) openTime.value = picked;
      else closeTime.value = picked;
    }
  }


  Future<String?> _uploadFile(String path, {String? filePath, Uint8List? bytes}) async {
    try {
      final ref = _storage.ref().child(path);
      UploadTask task = kIsWeb ? ref.putData(bytes!) : ref.putFile(File(filePath!));
      final snap = await task;
      return await snap.ref.getDownloadURL();
    } catch (e) {
      Get.snackbar("Upload Error", "Failed to upload file: $e");
      return null;
    }
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period";
  }

  TimeOfDay? _parseTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    try {
      final format = DateFormat("hh:mm a");
      final dt = format.parse(timeString);
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (e) {
      return null;
    }
  }

  // ✅ SMART METHOD: Decides whether to add a new shop or update an existing one
  Future<void> saveOrUpdateShop() async {
    if (isEditMode.value) {
      await updateShop(currentShopId!);
    } else {
      await addShop();
    }
  }


  Future<void> addShop() async {
    // Basic validation
    if (BusinessNameController.text.isEmpty || contactController.text.isEmpty) {
      Get.snackbar("Validation", "Business name & contact required", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      final userEmail = FirebaseAuth.instance.currentUser?.email ?? "admin@miogra.com";
      final shopId = uuid.v4();

      String? profileUrl;
      if (profileImage.value != null) {
        final img = profileImage.value!;
        profileUrl = await _uploadFile(
          "Business/$userEmail/Shops/$shopId/profile.jpg",
          filePath: kIsWeb ? null : img.path,
          bytes: kIsWeb ? await img.readAsBytes() : null,
        );
      }

      Map<String, String> docUrls = {};
      for (var entry in uploadedDocs.entries) {
        final docFile = entry.value;
        if (docFile != null) {
          final url = await _uploadFile(
            "Business/$userEmail/Shops/$shopId/${entry.key}.pdf",
            filePath: docFile.path,
            bytes: docFile.bytes,
          );
          if (url != null) docUrls[entry.key] = url;
        }
      }

      Map<String, dynamic> businessData = _buildBusinessDataMap();
      businessData['profileImage'] = profileUrl;
      businessData['documents'] = docUrls;
      businessData['createdAt'] = FieldValue.serverTimestamp();
      businessData['id'] = userEmail;
      businessData['addedBy'] = userEmail;
      businessData['status'] = "Pending";

      // ✅ UPDATED: Storing the generated shopId inside the document as well
      businessData['shopId'] = shopId;


      WriteBatch batch = _firestore.batch();
      final businessShopRef = _firestore.collection("Business").doc(userEmail).collection("Shops").doc(shopId);
      batch.set(businessShopRef, businessData);
      final globalShopRef = _firestore.collection("Shops").doc(shopId);
      batch.set(globalShopRef, businessData);
      await batch.commit();

      Get.snackbar("Success", "Shop added successfully!", backgroundColor: Colors.green, colorText: Colors.white);
      clearAllFields();
      Get.back();
    } catch (e) {
      Get.snackbar("Error", "Failed to add shop: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }


  // ✅ NEW: Updates an existing shop document
  Future<void> updateShop(String businessId) async {
    isLoading.value = true;
    try {
      final userEmail = FirebaseAuth.instance.currentUser?.email ?? "admin@miogra.com";

      String? profileUrl = networkImage.value; // Start with existing image
      if (profileImage.value != null) { // If a new image was picked, upload it
        final img = profileImage.value!;
        profileUrl = await _uploadFile(
          "Business/$userEmail/Shops/$businessId/profile.jpg",
          filePath: kIsWeb ? null : img.path,
          bytes: kIsWeb ? await img.readAsBytes() : null,
        );
      }

      // Start with existing docs and update with new ones
      Map<String, String> docUrls = Map.from(existingDocs);
      for (var entry in uploadedDocs.entries) {
        final docFile = entry.value;
        if (docFile != null) {
          final url = await _uploadFile(
            "Business/$userEmail/Shops/$businessId/${entry.key}.pdf",
            filePath: docFile.path,
            bytes: docFile.bytes,
          );
          if (url != null) docUrls[entry.key] = url;
        }
      }

      Map<String, dynamic> updatedData = _buildBusinessDataMap();
      updatedData['profileImage'] = profileUrl;
      updatedData['documents'] = docUrls;
      updatedData['updatedAt'] = FieldValue.serverTimestamp();

      WriteBatch batch = _firestore.batch();
      final businessShopRef = _firestore.collection("Business").doc(userEmail).collection("Shops").doc(businessId);
      batch.update(businessShopRef, updatedData);
      final globalShopRef = _firestore.collection("Shops").doc(businessId);
      batch.update(globalShopRef, updatedData);
      await batch.commit();

      Get.snackbar("Success", "Shop updated successfully!", backgroundColor: Colors.green, colorText: Colors.white);
      clearAllFields();
      Get.back();
    } catch (e) {
      Get.snackbar("Error", "Failed to update shop: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ NEW: Helper to build the data map, used by both add and update
  Map<String, dynamic> _buildBusinessDataMap() {
    return {
      "name": BusinessNameController.text.trim(),
      "ownerName": nameController.text.trim(),
      "BankName": bankNameController.text.trim(),
      "contact": contactController.text.trim(),
      "emergencyContact": emergencyContact2.text.trim(),
      "aadhar": aadharController.text.trim(),
      "pan": panController.text.trim(),
      "GST": GSTController.text.trim(),
      "fssai": fssaiController.text.trim(),
      "accountNumber": accountNumberController.text.trim(),
      "ifsc": ifscController.text.trim(),
      "upi": upiIdController.text.trim(),
      "UPINumber": upiIdController.text.trim(),
      "customerZone": customerZone.value,
      "GpayNumber": gpay.text.trim(),
      "deliveryZone": deliveryZone.value,
      "deliveryZoneCoordinates": selectedDeliveryZoneData?['zonePoints'] ?? [],
      "deliveryZoneId": selectedDeliveryZoneData?['zoneId'] ?? "",
      "address": "${doorController.text}, ${streetController.text}, ${areaController.text}, PIN: ${pinController.text}",
      "openTime": formatTime(openTime.value),
      "closeTime": formatTime(closeTime.value),
      "selectedCategories": selectedCategories.toList(),
      "DoorNo": doorController.text.trim(),
      "Street": streetController.text.trim(),
      "area": areaController.text.trim(),
      "location": {
        "latitude": selectedLat ?? 0,
        "longitude": selectedLng ?? 0,
        "placeName": selectedPlaceName ?? "",
      },
    };
  }


  void clearAllFields() {
    nameController.clear();
    BusinessNameController.clear();
    aadharController.clear();
    panController.clear();
    GSTController.clear();
    contactController.clear();
    emergencyContact2.clear();
    doorController.clear();
    streetController.clear();
    areaController.clear();
    pinController.clear();
    fssaiController.clear();
    accountNumberController.clear();
    ifscController.clear();
    upiIdController.clear();
    bankNameController.clear();
    gpay.clear();

    profileImage.value = null;
    networkImage.value = null;
    uploadedDocs.clear();
    existingDocs.clear();
    selectedCategories.clear();
    customerZone.value = "";
    deliveryZone.value = "";

    openTime.value = const TimeOfDay(hour: 9, minute: 0);
    closeTime.value = const TimeOfDay(hour: 22, minute: 0);
    selectedLat = null;
    selectedLng = null;
    selectedPlaceName = null;

    isEditMode.value = false;
    currentShopId = null;

    update();
  }
}

