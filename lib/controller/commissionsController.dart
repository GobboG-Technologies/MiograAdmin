import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class CommissionGSTController extends GetxController {
  var incentive = "".obs;
  var deliveryDistance = "".obs;
  var foodCommission = "".obs;
  var foodGST = "".obs;
  var freshCutCommission = "".obs;
  var freshCutGST = "".obs;
  var pharmacyCommission = "".obs;
  var pharmacyGST = "".obs;

  final TextEditingController incentiveController = TextEditingController();
  final TextEditingController deliveryDistanceController = TextEditingController();
  final TextEditingController foodCommissionController = TextEditingController();
  final TextEditingController foodGSTController = TextEditingController();
  final TextEditingController freshCutCommissionController = TextEditingController();
  final TextEditingController freshCutGSTController = TextEditingController();
  final TextEditingController pharmacyCommissionController = TextEditingController();
  final TextEditingController pharmacyGSTController = TextEditingController();
}