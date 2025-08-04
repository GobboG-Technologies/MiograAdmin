import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/termsandconditioinControllers.dart';


class UserFormPage extends StatelessWidget {
  final UserFormController controller = Get.put(UserFormController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Center(
              child: Container(
                width: MediaQuery.sizeOf(context).width/3,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildTabButton('End User',0, controller),
                    _buildTabButton('Business', 1,controller),
                    _buildTabButton('Delivery', 2,controller),
                  ],
                ),
              ),
            )),

            SizedBox(height: 30),

            Center(
              child: TextButton(
                onPressed: () {},
                child: Text('+ Add', style: TextStyle(color: Colors.green, fontSize: 26,fontWeight: FontWeight.bold)),
              ),
            ),

            SizedBox(height: 50),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                    Obx(() => _buildInputField('Title',maxLines: 2,
                      controllers: controller.titleControllers[controller.selectedTab.value],
                      onChanged: (text) => controller.updateTitle(text),)),
                      SizedBox(height: 10),
                      Obx(() => _buildInputField('Description', maxLines: 10,
                          controllers: controller.descriptionControllers[controller.selectedTab.value],
                        onChanged: (text) => controller.updateDescription(text),),
                      )],
                  ),
                ),

                SizedBox(width: 20),

                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Use of Services',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 10),
                      Text(
                        'You must be at least 18 years old to use our Services. By using our Services, you represent and warrant that you meet this age requirement.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width/8,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Close', style: TextStyle(color: Colors.orange)),
                  ),
                ),

                SizedBox(width: 12),

                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width/8 ,
                  child: ElevatedButton(
                    onPressed: () { _saveTerms(controller);},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5D348B),
                      disabledForegroundColor: Colors.white.withOpacity(0.6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Save', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTabButton(String title, int index, UserFormController controller) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.selectedTab.value = index;
        },
        child: Container(
          decoration: BoxDecoration(
            color: controller.selectedTab.value == index
                ? Color(0xFF5D348B)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: controller.selectedTab.value == index
                  ? Colors.white
                  : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String hint, {int maxLines = 1,required TextEditingController controllers, required Function(String) onChanged}) {

      return TextField(
      maxLines: maxLines,
      controller: controllers,
        onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        hintText: hint,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  // Save Terms Function
  void _saveTerms(UserFormController controller) {
    int tab = controller.selectedTab.value;
    String savedText = controller.terms[tab]!.value;

    // Replace this with Firestore save logic
    print("Saved Terms for Tab $tab: $savedText");

    Get.snackbar(
      "Saved",
      "Terms & Conditions saved successfully!",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
