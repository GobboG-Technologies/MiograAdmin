import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlockDashboardController extends GetxController {
  var selectedTab = "Seller".obs; // Default selected tab
  var selectedZone = "Zone 1".obs; // Default zone selection
  var selectedBusinessType = "Retail".obs;
  var selectedCategory = "Category A".obs;

  // Change selected tab
  void changeTab(String tab) {
    selectedTab.value = tab;
  }
}

class BlockDashboardPage extends StatelessWidget {
  final BlockDashboardController controller = Get.put(BlockDashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// **Top Navigation Tabs (Single Container)**
            Obx(() => Center(
              child: Container(
                width: MediaQuery.of(context).size.width / 2,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ["Seller", "Business", "Product", "Delivery"]
                      .map((tab) => GestureDetector(
                    onTap: () => controller.changeTab(tab),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 60),
                      decoration: BoxDecoration(
                        color: controller.selectedTab.value == tab ? Colors.purple[900] : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          color: controller.selectedTab.value == tab ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ),
            )),
            SizedBox(height: 20),

            /// **Dropdowns & Filter Button**
            Obx(() {
              bool isBusinessTab = controller.selectedTab.value == "Business";
              return Row(
                children: [
                  // **Dropdown 1: Always Visible (Zone Selection)**

                  Container(
                    width:250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[300],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: controller.selectedZone.value,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          border: InputBorder.none),
                      items: ["Zone 1", "Zone 2", "Zone 3"]
                          .map((zone) => DropdownMenuItem(value: zone, child: Text(zone)))
                          .toList(),
                      onChanged: (value) => controller.selectedZone.value = value!,
                    ),
                  ),

                  SizedBox(width: 16),

                  // **Dropdowns for Business Tab (Only Visible for Business)**
                  if (isBusinessTab) ...[
                    SizedBox(width: 16),
                    Container(
                      width:250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: controller.selectedCategory.value,
                        decoration: InputDecoration
                          (border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                        items: ["Category A", "Category B", "Category C"]
                            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (value) => controller.selectedCategory.value = value!,
                      ),
                    ),
                    SizedBox(width: 16),
                  ],

                  // **Filter Button (Always Visible)**
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5D348B),
                        padding: EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),),
                      onPressed: () {  },
                      child:Row(
                        children: [
                          Text("Filter",style: TextStyle(color: Colors.white),),
                          SizedBox(width: 5,),
                          Icon(Icons.filter_alt_outlined,color: Colors.white,),
                        ],
                      )),],
              );
            }),

            SizedBox(height: 50),

            /// **Dynamic Content (Cards)**
            Expanded(
              child: Obx(() {
                var currentTab = controller.selectedTab.value;
                var cardList = getCardData(currentTab); // Get cards based on tab

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: cardList.length,
                  itemBuilder: (context, index) {
                    var card = cardList[index];

                    return Container(
                      // padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  card["image"]!,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(card["name"]!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 5),
                                    Text("ID: ${card["id"]}", style: TextStyle(color: Colors.purple[900], fontSize: 12)),
                                    SizedBox(height: 5),
                                    Text(card["phone"]!, style: TextStyle(fontSize: 12)),
                                    SizedBox(height: 5),
                                    Text(card["email"]!, style: TextStyle(fontSize: 12)),
                                    SizedBox(height: 5),
                                    Text("● Blocked", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(card["address"]!,
                                style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ),
                          Expanded(child: SizedBox()),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.purple[900],
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                            ),
                            child: Center(
                              child: Text("✎ Edit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// **Mock Data for Different Tabs**
  List<Map<String, String>> getCardData(String category) {
    if (category == "Seller") {
      return [
        {"name": "Abilash",
          "id": "SID98765432101",
          "phone": "+91 9876543210",
          "email": "abilashabi@gmail.com",
          "address": "TMJ complex, Tamil Nadu...Asjakdjsfjdafjldfnkdsjfkdjfdksfdkfldkf",
          "image": "assets/images/img5.png"},
        {"name": "Abilash",
          "id": "SID98765432101",
          "phone": "+91 9876543210",
          "email": "abilashabi@gmail.com",
          "address": "TMJ complex, Tamil Nadu...Asjakdjsfjdafjldfnkdsjfkdjfdksfdkfldkf",
          "image": "assets/images/img5.png"},
      ];
    } else if (category == "Business") {
      return [
        {"name": "Alice Smith", "id": "BID5678901234", "phone": "+91 9988776655", "email": "alice@gmail.com", "address": "Park Street, Kolkata", "image": "assets/images/img5.png"},
        {"name": "Alice Smith", "id": "BID5678901234", "phone": "+91 9988776655", "email": "alice@gmail.com", "address": "Park Street, Kolkata", "image": "assets/images/img5.png"},

      ];
    }else if (category == "Product") {
      return[
        {"name": "Alice Smith", "id": "BID5678901234", "phone": "+91 9988776655", "email": "alice@gmail.com", "address": "Park Street, Kolkata", "image": "assets/images/img6.png"},
        {"name": "Alice Smith", "id": "BID5678901234", "phone": "+91 9988776655", "email": "alice@gmail.com", "address": "Park Street, Kolkata", "image": "assets/images/img6.png"},

      ];

    }
    else if (category == "Delivery") {
      return[
        {"name": "Alice Smith", "id": "BID5678901234", "phone": "+91 9988776655", "email": "alice@gmail.com", "address": "Park Street, Kolkata", "image": "assets/images/img5.png"},
        {"name": "Alice Smith", "id": "BID5678901234", "phone": "+91 9988776655", "email": "alice@gmail.com", "address": "Park Street, Kolkata", "image": "assets/images/img6.png"},

      ];

    }
    return [];
  }
}