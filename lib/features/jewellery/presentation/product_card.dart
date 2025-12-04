import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey.shade200,
              child: const Center(child: Text("Image")),
            ),
          ),
          const SizedBox(height: 8),
          const Text("Product Name"),
          const Text("₹ 50,000", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
