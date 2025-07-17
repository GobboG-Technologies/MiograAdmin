import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miogra_admin/elements/payment/payment_frame.dart';

import '../../controller/paymentController.dart';



class PaymentFloatingPage extends StatelessWidget {
  paymentController paymentcontroller = Get.put(paymentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: LayoutBuilder(
        builder: (context, constraints) {
          // Adjust columns based on screen size
          int crossAxisCount = (constraints.maxWidth ~/ 300).clamp(1, 4);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: paymentcontroller.payment.length,
              itemBuilder: (context, index) {
                final store = paymentcontroller.payment[index];
                return StoreCard(
                    id: store['id']!,
                    name: store['name']!,
                    phone: store['phone']!,
                    location: store['location']!,
                    Restname: store['Restname']!,
                    address: store['address']!,
                    price: store['price']!,
                    image: store['image']!,
                    status: store['status']!,
                    floating  :store['floating cash']!
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class StoreCard extends StatelessWidget {
  final String id, location, name, address, price, image ,Restname ,phone,status,floating;

  const StoreCard({
    required this.id,
    required this.location,
    required this.name,
    required this.address,
    required this.price,
    required this.image,
    required this.phone,
    required this.Restname,
    required this.status,
    required this.floating
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'active' ? Colors.green : Colors.orange;
    String buttonText = status == 'active' ? "Go Live" : "Request";
    Color buttonColor = status == 'active' ? Colors.green : Colors.purple;
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                // borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(image, height: 120, width: 120, fit: BoxFit.cover),
              ),
              Expanded(
                child:Padding(
                  padding: EdgeInsets.all(15),
                  child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black)),
                          Spacer(),
                          // Status Indicator
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text("ID: $id", style: TextStyle(color: Colors.purple[900], fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("+91 $phone", style: TextStyle(color: Colors.purple[900], fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.purple[900], size: 20),
                          Text(location, style: TextStyle(color: Colors.grey[500],fontWeight: FontWeight.bold,fontSize: 12)),
                        ],
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Expanded(
          //   child:
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40,
                  child: Text(address, style: TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis, maxLines: 2),
                ),
                SizedBox(height: 8),
                // Floating Cash
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    // borderRadius: BorderRadius.circular(8),

                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Floating Cash",
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.currency_rupee_sharp,
                        color: Colors.red,
                      ),
                      Text(
                        floating,
                        style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Request/Go Live Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text(buttonText, style: TextStyle(color: Colors.white)),
                  ),
                ),
                // Row(
                //   children: [
                //     Text(price, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple[900])),
                //     Spacer(),
                //     Align(
                //       alignment: Alignment.centerRight,
                //       child: GestureDetector(
                //         onTap: () {
                //           Get.to(() => PaymentPage(),
                //               arguments: {'storeId': id,'price': price,'image' : image,'name' :name});
                //         },
                //         child: ClipRRect(
                //             borderRadius: BorderRadius.circular(5),
                //             child: Image.asset(
                //               'assets/images/pay.png', // Replace with your image path
                //               height: 30,
                //               width: 100,
                //               fit: BoxFit.cover,
                //             )),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
          //),
        ],
      ),
    );

  }
}
