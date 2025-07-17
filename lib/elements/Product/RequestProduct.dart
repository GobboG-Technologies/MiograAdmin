
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../Models/RequestProductModel.dart';
import '../../controller/RequestProductCon.dart';

class RequestProductCard extends StatelessWidget {
  final RequestProduct product;
  final int index;
  final RequestProductController controller;

  RequestProductCard({required this.product, required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Opacity(
        opacity: product.isRejected.value ? 0.5 : 1.0, // Reduce opacity when rejected
        child: IgnorePointer( // Disable interaction when rejected
            ignoring: product.isRejected.value,
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image and Name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(product.imageUrl, height: 100, width: 100, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 10),
                              Icon(Icons.restaurant_menu, color: product.option ? Colors.green : Colors.red, size: 30),
                              const SizedBox(height: 10),
                              Text("ID: ${product.id}", style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Quantity, Seller Price, Selling Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Quantity Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.purple[900],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text("${product.quantity}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              const Text("QTY", style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),

                        // Seller Price
                        Column(
                          children: [
                            Text("₹ ${product.sellerPrice}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Text("Seller Price", style: TextStyle(fontSize: 12, color: Colors.black)),
                          ],
                        ),

                        // Selling Price
                        Column(
                          children: [
                            Text("₹ ${product.sellingPrice}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Text("Selling Price", style: TextStyle(fontSize: 12, color: Colors.black)),
                          ],
                        ),
                      ],
                    ),
                    Expanded(child: SizedBox()),

                    // Approve & Reject Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Reject Button
                        TextButton(
                          onPressed:() => controller.rejectProduct(index),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          ),
                          child: const Text("Reject", style: TextStyle(color: Colors.red)),
                        ),

                        // Approve Button
                        Obx(() => TextButton(
                          onPressed: product.isRejected.value ? null : () => controller.toggleApproval(index),
                          style: TextButton.styleFrom(
                            backgroundColor: product.isApproved.value ? Colors.green : Colors.white,
                            side: BorderSide(color: product.isApproved.value ? Colors.green : Colors.green),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          ),
                          child: Text(
                            "Approve",
                            style: TextStyle(color: product.isApproved.value ? Colors.white : Colors.green),
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ) )),);
  }
}