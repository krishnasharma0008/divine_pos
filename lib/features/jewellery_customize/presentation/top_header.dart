import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopHeader extends StatelessWidget {
  final double r;
  final VoidCallback? onBack;
  final VoidCallback? onAddToCart;

  const TopHeader(this.r, {super.key, this.onBack, this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 * r,
      padding: EdgeInsets.symmetric(horizontal: 24 * r),
      color: const Color(0xFFD6F1EC),
      child: Row(
        children: [
          /// ✅ Back Button
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(30 * r),
            child: Icon(Icons.arrow_back, size: 20 * r),
          ),

          SizedBox(width: 12 * r),

          /// ✅ Title
          Text(
            //"Necklace / PDP",
            "",
            style: TextStyle(fontSize: 16 * r, fontWeight: FontWeight.w500),
          ),

          const Spacer(),

          /// ✅ Cart Button
          InkWell(
            onTap: onAddToCart,
            borderRadius: BorderRadius.circular(50 * r),
            child: Container(
              width: 36 * r,
              height: 36 * r,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/icons/mdi_cart.svg',
                width: 18 * r,
                height: 18 * r,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
