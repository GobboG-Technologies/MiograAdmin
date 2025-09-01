import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miogra_admin/controller/adminController.dart';
import 'adminViewProfile.dart';

class AdminCardPage extends StatelessWidget {
  final AdminControllerpage controller = Get.put(AdminControllerpage());

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
              Center(child: _buildSearchBar(controller)),
              const SizedBox(height: 50),

              // Reactive Grid
              Obx(() => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.6,
                ),
                itemCount: controller.filteredAdmins.length,
                itemBuilder: (context, index) {
                  final admin = controller.filteredAdmins[index];

                  return GestureDetector(
                    onTap: () {
                      Get.to(() => AdminProfilePreviewPage(admin: admin));
                    },
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                  child: admin.image.isNotEmpty
                                      ? Image.network(
                                    admin.image,
                                    height: 200,
                                    width: 100,
                                    fit: BoxFit.fill,
                                  )
                                      : Image.asset(
                                    "assets/images/img6.png",
                                    height: 200,
                                    width: 100,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(admin.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                            fontSize: 20)),
                                    const SizedBox(height: 15),
                                    Text(admin.phone,
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 15),
                                    Text(admin.email,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15)),
                                    const SizedBox(height: 15),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on,
                                            color: Colors.purple[900]),
                                        Text(admin.location,
                                            style: TextStyle(
                                                color: Colors.purple[900],
                                                fontSize: 15)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  // Search Bar
  Widget _buildSearchBar(AdminControllerpage controller) {
    return Container(
      width: 600,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          hintText: "Search by Name or Zone",
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
        ),
        onChanged: (value) {
          controller.searchQuery.value = value;
        },
      ),
    );
  }
}
