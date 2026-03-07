import 'package:flutter/material.dart';
import '../../data/diamond_config.dart';

class CaratSlider extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const CaratSlider({super.key, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum',
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: _buildSlider()),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: const Color(0xFFE4E4E0)),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Color(0xFF6B6B6B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        _buildLabels(),
      ],
    );
  }

  Widget _buildSlider() {
    return SliderTheme(
      data: _sliderTheme(),
      child: Slider(
        value: index.toDouble(),
        min: 0,
        max: (DiamondConfig.caratValues.length - 1).toDouble(),
        divisions: DiamondConfig.caratValues.length - 1,
        onChanged: (v) => onChanged(v.round()),
      ),
    );
  }

  Widget _buildLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: DiamondConfig.caratValues.map((v) {
        final i = DiamondConfig.caratValues.indexOf(v);
        return Text(
          v,
          style: TextStyle(
            fontSize: 9,
            color: i == index ? const Color(0xFF3AA09A) : Colors.grey[400],
            fontWeight: i == index ? FontWeight.w500 : FontWeight.w300,
          ),
        );
      }).toList(),
    );
  }

  SliderThemeData _sliderTheme() {
    return SliderThemeData(
      activeTrackColor: const Color(0xFF8FBFB5),
      inactiveTrackColor: const Color(0xFFDDDDDD),
      thumbColor: const Color(0xFF8FBFB5),
      overlayColor: const Color(0xFF8FBFB5).withOpacity(0.2),
      trackHeight: 3,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
    );
  }
}
