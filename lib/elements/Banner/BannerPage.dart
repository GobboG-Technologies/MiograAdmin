import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Models/Banner_Model.dart';
import '../../controller/BannerController.dart';

class BannerPage extends StatelessWidget {
  final BannerController bannerController = Get.put(BannerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            /// 🔹 Zone Dropdown
            Align(
              alignment: Alignment.centerLeft,
              child: Obx(() {
                if (bannerController.zones.isEmpty) {
                  return const Text("No Zones");
                }
                return DropdownButton<String>(
                  value: bannerController.selectedZoneId.value,
                  hint: const Text("Select Zone"),
                  items: bannerController.zones.map((zone) {
                    return DropdownMenuItem<String>(
                      value: zone['zoneId'] as String,
                      child: Text(zone['zoneName'] as String),
                    );
                  }).toList(),
                  onChanged: (newValue) =>
                      bannerController.onZoneChanged(newValue),
                );
              }),
            ),

            const SizedBox(height: 20),

            /// Upload Button
            TextButton(
              onPressed: () => Get.dialog(BannerForm()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.cloud_upload, color: Colors.purple[900]),
                  const SizedBox(width: 5),
                  Text(
                    "Upload Banner",
                    style: TextStyle(
                      color: Colors.purple[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Table Container
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey[300],
                ),
                child: Column(
                  children: [
                    /// Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      color: Colors.grey[300],
                      child: Row(
                        children: [
                          _headerCell("Image"),
                          _headerCell("Name"),
                          _headerCell("Duration"),
                          _headerCell("Redirect To"),
                          _headerCell("Action"),
                        ],
                      ),
                    ),
                    const Divider(thickness: 2, color: Colors.black),

                    /// Table Data (Vertical Alignment)
                    Expanded(
                      child: Obx(() {
                        // 🔹 filter banners by selected zone if you want
                        final filteredBanners =
                            bannerController.banners; // simple for now

                        return SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Image Column
                              _columnCell(
                                children: filteredBanners.map((banner) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Container(
                                      width: 120,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black12),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: banner.imageBytes.isNotEmpty
                                          ? ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Image.memory(
                                          banner.imageBytes,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                          : Container(
                                        color: Colors.grey,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              /// Name Column
                              _columnCell(
                                children: filteredBanners.map((banner) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 35),
                                    child: Text(
                                      banner.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              /// Duration Column
                              _columnCell(
                                children: filteredBanners.map((banner) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: Column(
                                      children: [
                                        Text(
                                          banner.startDate,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const Text("TO",
                                            style: TextStyle(fontSize: 12)),
                                        Text(
                                          banner.endDate,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),

                              /// Redirect Column
                              _columnCell(
                                children: filteredBanners.map((banner) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 35),
                                    child: Text(
                                      banner.category,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              /// Action Column (Toggle + Edit + Delete)
                              _columnCell(
                                children: filteredBanners
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  BannerModel banner = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        /// Toggle
                                        Switch(
                                          value: banner.isActive,
                                          onChanged: (value) =>
                                              bannerController.toggleBannerStatus(index),
                                          activeColor: Colors.green,
                                        ),

                                        /// Edit
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () => Get.dialog(
                                            BannerForm(
                                              isEdit: true,
                                              banner: banner,
                                              index: index,
                                            ),
                                          ),
                                        ),

                                        /// Delete
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              bannerController.removeBanner(index),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header Cell Widget
  Widget _headerCell(String text) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Column Cell Widget
  Widget _columnCell({required List<Widget> children}) {
    return Expanded(
      child: Column(
        children: children,
      ),
    );
  }
}

class BannerForm extends StatelessWidget {
  final bool isEdit;
  final BannerModel? banner;
  final int? index;

  const BannerForm({super.key, this.isEdit = false, this.banner, this.index});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEdit ? "Edit Banner" : "Add Banner",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text("Form fields go here..."),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }
}
