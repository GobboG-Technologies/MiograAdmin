import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardController extends GetxController {
  var selectedZone = "".obs; // Default value
  var hasAlarm = false.obs; // Alarm status (true = show red icon)

  void toggleAlarm() {
    hasAlarm.value = !hasAlarm.value; // Toggle alarm status
  }

  void setZone(String zone) {
    selectedZone.value = zone; // Update selected zone
  }

  var stats = [
    {"title": "Customers", "count": "1000", "color": const Color(0xFF0F0FBA), "icons": Icons.people_outline},
    {"title": "Orders", "count": "5000", "color": const Color(0xFFEDA917), "icons": Icons.card_giftcard_outlined},
    {"title": "Restaurants", "count": "5000", "color": const Color(0xFFA032F4), "icons": Icons.business},
    {"title": "Products", "count": "5000", "color": const Color(0xFF171717), "icons": Icons.inventory_2},

    {"title": "Unassigned \n Orders", "count": "5000", "color": const Color(
        0xFFFF8800), "icons": Icons.unpublished_outlined},
    {"title": "Accepted by \n Delivery Man", "count": "5000", "color": const Color(
        0xFF1FCD3D), "icons": Icons.gpp_good_outlined},
    {"title": "Packaging", "count": "5000", "color": const Color(0xFF26A69A), "icons": Icons.calculate},
    {"title": "Out of \n delevery", "count": "5000", "color": const Color(
        0xFF123DC8), "icons": Icons.local_shipping },

    {"title": "Delivered", "count": "50", "color": const Color(0xFF1BC538), "icons": Icons.system_security_update_good},
    {"title": "Cancelled", "count": "30", "color": const Color(0xFFEA3C3C), "icons": Icons.cancel_presentation},
    {"title": "Refunde", "count": "10", "color": const Color(0xFFDF332A), "icons": Icons.attach_money},
    {"title": "Payment \n Failed", "count": "500", "color": const Color(0xFF731410), "icons": Icons.sms_failed_outlined},
  ].obs;
}
