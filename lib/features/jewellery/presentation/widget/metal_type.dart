import 'package:flutter/material.dart';

class MetalTypeGrid extends StatelessWidget {
  final double fem;
  final List<Map<String, String>> items; // [{label, asset}]
  final Set<String> selected; // from FilterState.selectedMetal
  final void Function(String metal)? onSelected;

  const MetalTypeGrid({
    super.key,
    this.fem = 1.0,
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
      childAspectRatio: 2.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
              vertical: 10 * fem,
            ),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEFF8F7) : Colors.white,
              borderRadius: BorderRadius.circular(15 * fem),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFE5C289)
                    : const Color(0xFFEDEDED),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12 * fem,
                  height: 12 * fem,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Image.asset(asset, fit: BoxFit.contain),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14 * fem,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF555555),
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
