import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/deliveryPersonCon.dart';
import '../Business/business_dropdown.dart';
import 'AddDeliveryPerson.dart';
import 'EditDeliveryPersonPage.dart';

class DeliveryCardPage extends StatelessWidget {
  final DeliveryPersonController controller = Get.put(DeliveryPersonController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Obx(() {
                    if (controller.zones.isEmpty) {
                      return const Text("No Zones");
                    }
                    return DropdownButton<String>(
                      value: controller.selectedZoneId.value,
                      hint: const Text("Select Zone"),
                      items: controller.zones.map((zone) {
                        return DropdownMenuItem<String>(
                          value: zone['zoneId'] as String,
                          child: Text(zone['zoneName'] as String),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        controller.onZoneChanged(newValue);
                      },
                    );
                  }),
                  const Spacer(),
                  // Assuming FilterWidget is a defined widget
                  // FilterWidget(),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Get.to(() => AddDeliveryPersonPage());
                    },
                    child: Text(
                      "+ Add Delivery",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8, // Adjust aspect ratio for better fit
                  ),
                  itemCount: controller.deliveryPersons.length,
                  itemBuilder: (context, index) {
                    final deliveryPerson = controller.deliveryPersons[index];

                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                  child: deliveryPerson.imageUrl.isNotEmpty
                                      ? Image.network(
                                    deliveryPerson.imageUrl,
                                    height: 120, // Adjusted height
                                    width: 80, // Adjusted width
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 120,
                                        width: 80,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.person, size: 40, color: Colors.grey),
                                      );
                                    },
                                  )
                                      : Container(
                                    height: 120,
                                    width: 80,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.person, size: 40, color: Colors.grey),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        deliveryPerson.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                          fontSize: 20,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "ID: ${deliveryPerson.id}",
                                        style: TextStyle(
                                          color: Colors.purple[900],
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        deliveryPerson.phone,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        deliveryPerson.email,
                                        style: TextStyle(color: Colors.black, fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            color: deliveryPerson.isAvailable ? Colors.green : Colors.red,
                                            size: 12,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            deliveryPerson.isAvailable ? "Live" : "Offline",
                                            style: TextStyle(
                                              color: deliveryPerson.isAvailable ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Text(
                              deliveryPerson.address,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.purple[900],
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(12),
                              ),
                            ),
                            width: double.infinity,
                            height: 50,
                            child: TextButton.icon(
                              onPressed: () {
                                // *** ACTION TO NAVIGATE TO THE EDIT PAGE ***
                                Get.to(() => EditDeliveryPersonPage(deliveryPersonId: deliveryPerson.id));
                              },
                              icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                              label: const Text(
                                "Edit",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}