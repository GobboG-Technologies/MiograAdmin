import 'package:flutter/material.dart';
import '../../Models/RequestProductModel.dart';
import '../../controller/RequestProductCon.dart';
import 'package:get/get.dart';

class RequestProductCard extends StatelessWidget {
  final RequestProduct product;
  final int index;
  final RequestProductController controller;

  RequestProductCard({
    required this.product,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Opacity(
      opacity: product.isRejected.value ? 0.5 : 1.0,
      child: IgnorePointer(
        ignoring: product.isRejected.value,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrl,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 5),
                          Text("ID: ${product.id}", style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(children: [Text("${product.quantity}"), const Text("QTY")]),
                    Column(children: [Text("₹ ${product.sellerPrice}"), const Text("Seller Price")]),
                    Column(children: [Text("₹ ${product.sellingPrice}"), const Text("Selling Price")]),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => controller.rejectProduct(index),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                      child: const Text("Reject", style: TextStyle(color: Colors.red)),
                    ),
                    TextButton(
                      onPressed: () => controller.toggleApproval(index),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                      child: const Text("Approve", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
