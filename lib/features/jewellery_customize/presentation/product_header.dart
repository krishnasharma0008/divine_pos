import 'package:flutter/material.dart';

class ProductHeader extends StatelessWidget {
  final double r;
  const ProductHeader(this.r, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Best Seller",
              style: TextStyle(color: Colors.orange, fontSize: 12 * r),
            ),
            SizedBox(width: 6 * r),
            Icon(
              Icons.local_fire_department,
              size: 16 * r,
              color: Colors.orange,
            ),
          ],
        ),
        SizedBox(height: 8 * r),
        Text(
          "Eternal Radiance Necklace For Her",
          style: TextStyle(fontSize: 18 * r, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 6 * r),
        Text(
          "Gracefully crafted in 18K gold, this solitaire necklace...",
          style: TextStyle(fontSize: 13 * r, color: Colors.grey),
        ),
      ],
    );
  }
}
