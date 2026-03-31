import 'package:flutter/material.dart';

import '../../../../shared/widgets/text.dart';

class DiamondShape {
  final String type;
  final String label;
  final String value;
  final String assetPath;

  const DiamondShape({
    required this.type,
    required this.label,
    required this.value,
    required this.assetPath,
  });
}

class ShapeSelector extends StatelessWidget {
  final String selectedShape;
  final int initialIndex;
  final ValueChanged<DiamondShape> onShapeChanged;

  const ShapeSelector({
    super.key,
    required this.selectedShape,
    required this.initialIndex,
    required this.onShapeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final allShapes = <DiamondShape>[
      const DiamondShape(
        type: 'SOLITAIRE',
        label: 'Round',
        value: 'RND',
        assetPath: 'assets/diamond_value/round.png',
      ),
      const DiamondShape(
        type: 'SOLITAIRE',
        label: 'Princess',
        value: 'PRN',
        assetPath: 'assets/diamond_value/princess.png',
      ),
      const DiamondShape(
        type: 'SOLITAIRE',
        label: 'Pear',
        value: 'PER',
        assetPath: 'assets/diamond_value/pear.png',
      ),
      const DiamondShape(
        type: 'SOLITAIRE',
        label: 'Oval',
        value: 'OVL',
        assetPath: 'assets/diamond_value/oval.png',
      ),
      const DiamondShape(
        type: 'SOLUS',
        label: 'Radiant',
        value: 'RADQ',
        assetPath: 'assets/diamond_value/radiant.png',
      ),
      const DiamondShape(
        type: 'SOLUS',
        label: 'Cushion',
        value: 'CUSQ',
        assetPath: 'assets/diamond_value/cushion.png',
      ),
      const DiamondShape(
        type: 'SOLUS',
        label: 'Heart',
        value: 'HRT',
        assetPath: 'assets/diamond_value/heart.png',
      ),
    ];

    final hasValidInitialIndex =
        initialIndex >= 0 && initialIndex < allShapes.length;

    final fallbackSelectedShape = hasValidInitialIndex
        ? allShapes[initialIndex].value
        : '';

    final currentSelectedShape = selectedShape.isNotEmpty
        ? selectedShape
        : fallbackSelectedShape;

    return Container(
      width: double.infinity,
      // padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(22),
      //   border: Border.all(color: const Color(0xFFCFE8E3), width: 1.2),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText(
            'Shape',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: allShapes.map((shape) {
                final isSelected = currentSelectedShape == shape.value;

                return Padding(
                  padding: const EdgeInsets.only(right: 26),
                  child: _ShapeItem(
                    label: shape.label,
                    assetPath: shape.assetPath,
                    isSelected: isSelected,
                    onTap: () => onShapeChanged(shape),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShapeItem extends StatelessWidget {
  final String label;
  final String assetPath;
  final bool isSelected;
  final VoidCallback onTap;

  const _ShapeItem({
    required this.label,
    required this.assetPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6F6F6F),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            width: 70,
            height: 74,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF8FFFD) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFB8E0D8)
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              width: 38,
              height: 38,
            ),
          ),
        ],
      ),
    );
  }
}
