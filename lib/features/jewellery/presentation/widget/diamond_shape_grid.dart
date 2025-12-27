import 'package:flutter/material.dart';

import '../../../../shared/widgets/text.dart';

class DiamondShapeGrid extends StatelessWidget {
  final double fem;
  final List<Map<String, String>> items; // [{label, asset}]
  final Set<String> selected; // from FilterState.selectedShape
  final void Function(String shape)? onSelected;

  const DiamondShapeGrid({
    super.key,
    required this.fem,
    required this.items,
    required this.selected,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12 * fem,
      crossAxisSpacing: 12 * fem,
      childAspectRatio: 3.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(left: fem * 0, right: fem * 23),
      children: items.map((it) {
        final String label = it['label']!;
        final String asset = it['asset']!;
        final bool isSelected = selected.contains(label);

        return GestureDetector(
          onTap: () => onSelected?.call(label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: 14 * fem,
              vertical: 4 * fem,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFF3FBFA) //.withValues(alpha: 0.11)
                  : const Color(0xFFFBFBFB),
              borderRadius: BorderRadius.circular(15 * fem),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFE5C289)
                    : Colors.transparent,
                //: const Color(0xFFEDEDED),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 29 * fem,
                  height: 29 * fem,
                  //decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Image.asset(asset, fit: BoxFit.cover),
                ),
                SizedBox(width: fem * 10),
                Expanded(
                  child: MyText(
                    label,
                    style: TextStyle(
                      fontSize: 14 * fem,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w400,
                      color: Color(0xFF4B4B4B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
