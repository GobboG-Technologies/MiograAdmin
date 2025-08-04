import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterController extends GetxController {

  var selectedCategory = "Select Category".obs;


  List<String> categories = ["Select Category", "Category 1", "Category 2", "Category 3"];
}

class FilterWidget extends StatelessWidget {
  final FilterController controller = Get.put(FilterController());

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Center elements
      children: [
        // Select Zone Dropdown


        SizedBox(width: 20), // Spacing

        // Select Category Dropdown
        Obx(() => _buildDropdown(controller.selectedCategory.value, controller.categories, (value) {
          controller.selectedCategory.value = value!;
        })),

        SizedBox(width: 20), // Spacing

        // Filter Button
        ElevatedButton.icon(
          onPressed: () {
            // Implement Filter Logic
          },
          icon: Icon(Icons.filter_list, color: Colors.white),
          label: Text("Filter", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[900], // Purple Background
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ],
    );
  }

  ///drop down
  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged) {
    return Material(
      color: Colors.transparent, // Transparent to keep the grey background
      child: Container(
        width: 200,
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Light Grey Background
          borderRadius: BorderRadius.circular(7),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
            style: TextStyle(color: Colors.grey[700], fontSize: 16),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

}
