import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';

class MetalTypeList extends StatelessWidget {
  final double fem;
  final double itemWidth; // ✅ configurable width
  final List<Map<String, String>> items;
  final Set<String> selected;
  final void Function(String metal)? onSelected;

  const MetalTypeList({
    super.key,
    this.fem = 1.0,
    this.itemWidth = 190, // 🎯 matches your image
    required this.items,
    required this.selected,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((it) {
        final String label = it['label']!;
        final String asset = it['asset']!;
        final bool isSelected = selected.contains(label);

        return Padding(
          padding: EdgeInsets.only(bottom: 12 * fem, left: 15),
          child: GestureDetector(
            onTap: () => onSelected?.call(label),
            child: SizedBox(
              width: itemWidth * fem, // ✅ FIXED WIDTH
              height: 44 * fem,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(horizontal: 16 * fem),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15 * fem),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFD6B37C)
                        : const Color(0xFFE6E6E6),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    // 🔹 Gold icon
                    Container(
                      width: 18 * fem,
                      height: 18 * fem,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                        ),
                      ),
                    ),

                    SizedBox(width: 12 * fem),

                    // 🔹 Text
                    Expanded(
                      child: MyText(
                        label,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14 * fem,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4A4A4A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
