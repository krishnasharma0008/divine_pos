import 'package:flutter/material.dart';
import '../../data/diamond_config.dart';

class ClaritySlider extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const ClaritySlider({
    super.key,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF8FBFB5),
            inactiveTrackColor: const Color(0xFFDDDDDD),
            thumbColor: const Color(0xFF8FBFB5),
            overlayColor: const Color(0xFF8FBFB5).withOpacity(0.2),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: index.toDouble(),
            min: 0,
            max: (DiamondConfig.clarityValues.length - 1).toDouble(),
            divisions: DiamondConfig.clarityValues.length - 1,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: DiamondConfig.clarityValues.asMap().entries.map((e) {
            final isSelected = e.key == index;
            return Text(
              e.value,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? const Color(0xFF3AA09A) : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
