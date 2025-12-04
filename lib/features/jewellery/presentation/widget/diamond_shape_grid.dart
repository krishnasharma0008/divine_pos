import 'package:flutter/material.dart';

class DiamondShapeGrid extends StatefulWidget {
  final double fem;
  final List<Map<String, String>> items; // [{label, asset}]
  final String? initialSelected;
  final void Function(String shape)? onSelected;

  const DiamondShapeGrid({
    super.key,
    this.fem = 1.0,
    required this.items,
    this.initialSelected,
    this.onSelected,
  });

  @override
  State<DiamondShapeGrid> createState() => _DiamondShapeGridState();
}

class _DiamondShapeGridState extends State<DiamondShapeGrid> {
  String? current;

  @override
  void initState() {
    super.initState();
    current = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    final fem = widget.fem;

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12 * fem,
      crossAxisSpacing: 12 * fem,
      childAspectRatio: 2.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: widget.items.map((it) {
        final String label = it['label']!;
        final String asset = it['asset']!;
        final bool isSelected = current == label;

        return GestureDetector(
          onTap: () {
            setState(() => current = label);
            widget.onSelected?.call(label);
          },
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
                  width: 48 * fem,
                  height: 48 * fem,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Image.asset(asset, fit: BoxFit.contain),
                ),
                //const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: isSelected ? 15 * fem : 14 * fem,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w400,
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
