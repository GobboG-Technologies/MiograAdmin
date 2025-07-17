import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../views/dashboard.dart';
import '../views/orders_view.dart';
import '../views/product_view.dart';
import '../views/business_view.dart';
import '../views/seller_view.dart';
import '../views/delivery_view.dart';
import '../views/customer_view.dart';
import '../views/banner_view.dart';
import '../views/blocklist_view.dart';
import '../views/payment_view.dart';
import '../views/admin_view.dart';

class SidebarController extends GetxController {
  RxInt selectedIndex = 0.obs;

  final List<Widget> pages = [
    DashboardView(),
    OrderPage(),
    ProductPage(),
    BusinessPage(),
    SellerPage(),
    DeliveryViewPage(),
    CustomerViewPage(),
    BannerViewPage(),
    BlockListViewPage(),
    PaymentViewPage(),
    AdminViewPage(),
  ];

  void changePage(int index) {
    selectedIndex.value = index;
  }
}
