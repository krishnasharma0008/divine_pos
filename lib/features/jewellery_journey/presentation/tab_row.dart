import 'package:flutter/material.dart';

class TabRowWidget extends StatelessWidget {
  final double r;
  final int activeTab;
  final ValueChanged<int> onTabSelected;

  const TabRowWidget(
    this.r, {
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _tabChip("Mount & Side Dia Selection", 0),
        SizedBox(width: 8 * r),
        _tabChip("Product Details", 1),
        SizedBox(width: 8 * r),
        _tabChip("Price Breakup", 2),
      ],
    );
  }

  Widget _tabChip(String title, int index) {
    final active = activeTab == index;

    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14 * r, vertical: 8 * r),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFD6F1EC) : Colors.transparent,
          borderRadius: BorderRadius.circular(20 * r),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12 * r,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
