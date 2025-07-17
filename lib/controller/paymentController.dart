import 'package:get/get.dart';

class paymentController extends GetxController{
  var selectedTab = 0.obs;
  final List<Map<String, String>> payment = [
    {
      'name':'Ajay',
      'phone':'123456987',
      'id': 'SID98765432101',
      'location': 'Nagercoil',
      'Restname': 'Bismi',
      'address': 'TMJ complex, Thiruvithankodu, Azahiamandapam, Tamil Nadu 629167',
      'price': '2500',
      'image': 'assets/images/img5.png',
      'floating cash' : '250',
      'status' : 'active'
    },
    {
      'name':'Ajay',
      'phone':'123456987',
      'id': 'SID98765432102',
      'location': 'Chennai',
      'Restname': 'Hello Biriyani',
      'address': 'XYZ complex, Chennai, Tamil Nadu 600001',
      'price': '3200',
      'image': 'assets/images/img5.png',
      'floating cash' : '250',
      'status' : 'live'
    },
    {
      'name':'Ajay',
      'phone':'123456987',
      'id': 'SID98765432103',
      'location': 'Coimbatore',
      'Restname': 'Biriyani Center',
      'address': 'ABC complex, Coimbatore, Tamil Nadu 641001',
      'price': '2800',
      'image': 'assets/images/img5.png',
      'floating cash' : '250',
      'status' : 'active'
    },
  ].obs;
}