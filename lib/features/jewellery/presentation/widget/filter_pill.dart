import 'package:flutter/material.dart';

import '../../../../shared/widgets/text.dart';

class FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final double fem;

  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = const Color(0xFFC8AC7D); // light gold
    const Color selectedBg = Color(0xFF90DCD0); // mint aqua
    const Color checkColor = Color(0xFF90DCD0); // checkmark

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 10 * fem, vertical: 8 * fem),
        decoration: BoxDecoration(
          color: selected ? Color(0xFFF3FBFA) : Color(0xFFFBFBFB),
          borderRadius: BorderRadius.circular(15 * fem),
          // ONLY selected has border
          border: selected
              ? Border.all(color: borderColor, width: 1 * fem)
              : Border.all(color: Colors.transparent, width: 1 * fem),
          // Color(0xFF90DCD0).withValues(alpha: 0.11)
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4 * fem,
                    offset: Offset(0, 2 * fem),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _checkbox(selected, fem),
            SizedBox(width: 8 * fem),
            MyText(
              label,
              style: TextStyle(
                fontSize: 14 * fem,
                fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                color: Color(0xFF4B4B4B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkbox(bool selected, double fem) {
    return Container(
      width: 18 * fem,
      height: 18 * fem,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5 * fem),

        // Background
        color: selected ? Color(0xFF90DCD0) : Colors.white,

        // Border (always same color)
        border: Border.all(
          color: const Color(0xFFC8AC7D), // checkbox border color
          width: 1.3 * fem,
        ),
      ),

      // Tick mark when selected
      child: selected
          ? const Icon(
              Icons.check,
              size: 14,
              color: Color(0xFFC8AC7D), // ✔ tick color
            )
          : null,
    );
  }
}
