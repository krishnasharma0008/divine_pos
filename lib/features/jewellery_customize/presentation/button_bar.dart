import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  final double r;
  const BottomBar(this.r, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76 * r,
      padding: EdgeInsets.symmetric(horizontal: 32 * r),
      decoration: BoxDecoration(
        color: const Color(0xFFD6F1EC),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16 * r),
        ),
      ),
      child: Row(
        children: [
          Text(
            "₹26,60,068",
            style: TextStyle(
              fontSize: 22 * r,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Container(
            width: 140 * r,
            height: 42 * r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFE8D8B2),
              borderRadius: BorderRadius.circular(22 * r),
            ),
            child: Text(
              "Continue",
              style: TextStyle(
                fontSize: 14 * r,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
