import 'package:flutter/material.dart';
import '../../data/diamond_config.dart';

class ShapeSelector extends StatelessWidget {
  final DiamondConfig config;
  final ValueChanged<DiamondShape> onShapeChanged;
  final ValueChanged<String> onYellowShapeChanged;

  const ShapeSelector({
    super.key,
    required this.config,
    required this.onShapeChanged,
    required this.onYellowShapeChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (config.isYellowColor) {
      return _buildYellowShapes();
    }
    return _buildNormalShapes();
  }

  Widget _buildNormalShapes() {
    final shapes = [
      (DiamondShape.round, 'Round', 'assets/diamond_value/round.png'),
      (DiamondShape.princess, 'Princess', 'assets/diamond_value/princess.png'),
      (DiamondShape.pear, 'Pear', 'assets/diamond_value/pear.png'),
      (DiamondShape.oval, 'Oval', 'assets/diamond_value/oval.png'),
    ];
    return Row(
      children: shapes.map((s) {
        final isSelected = config.shape == s.$1;
        return Padding(
          padding: const EdgeInsets.only(right: 14),
          child: _ShapeItem(
            label: s.$2,
            assetPath: s.$3,
            isSelected: isSelected,
            onTap: () => onShapeChanged(s.$1),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildYellowShapes() {
    final shapes = [
      ('Radiant', 'assets/diamond_value/radiant.png'),
      ('Cushion', 'assets/diamond_value/cushion.png'),
      ('Heart', 'assets/diamond_value/heart.png'),
    ];
    return Row(
      children: shapes.map((s) {
        final isSelected = config.yellowShape == s.$1;
        return Padding(
          padding: const EdgeInsets.only(right: 14),
          child: _ShapeItem(
            label: s.$1,
            assetPath: s.$2,
            isSelected: isSelected,
            onTap: () => onYellowShapeChanged(s.$1),
          ),
        );
      }).toList(),
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
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFD4ECE6)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF5AB5A8)
                    : const Color(0xFFE0E0E0),
                width: isSelected ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.all(5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(assetPath, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected
                  ? const Color(0xFF3AA09A)
                  : const Color(0xFF6B6B6B),
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
