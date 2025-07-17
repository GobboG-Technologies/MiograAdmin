import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miogra_admin/elements/payment/payment_frame.dart';

import '../../controller/paymentController.dart';



class PaymentDeliveryHistoryPage extends StatelessWidget {
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
                childAspectRatio: 1,
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
  final String id, location, name, address, price, image ,Restname ,phone;

  const StoreCard({
    required this.id,
    required this.location,
    required this.name,
    required this.address,
    required this.price,
    required this.image,
    required this.phone,
    required this.Restname
  });

  @override
  Widget build(BuildContext context) {
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
                         Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black)),
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
                  Row(
                    children: [
                      Text(price, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple[900])),
                      Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => PaymentPage(),
                                arguments: {'storeId': id,'price': price,'image' : image,'name' :name});
                          },
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.asset(
                                'assets/images/pay.png', // Replace with your image path
                                height: 30,
                                width: 100,
                                fit: BoxFit.cover,
                              )),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          //),
        ],
      ),
    );

  }
}
