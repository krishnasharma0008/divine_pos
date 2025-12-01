import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Price Range',
      home: Scaffold(
        appBar: AppBar(title: const Text('Price Range')),
        body: const Center(child: PriceRangeSelector(min: 10000, max: 1000000)),
      ),
    );
  }
}

class PriceRangeSelector extends StatefulWidget {
  final double min;
  final double max;

  const PriceRangeSelector({super.key, required this.min, required this.max});

  @override
  State<PriceRangeSelector> createState() => _PriceRangeSelectorState();
}

class _PriceRangeSelectorState extends State<PriceRangeSelector> {
  late RangeValues _currentRange;

  Color get _borderColor => const Color(0xFFD9C6A3); // Light brown border
  Color get _bgColor => const Color(0xFFEAF9F5); // Light mint/teal background
  Color get _textColor => const Color(0xFF20706F); // Deep teal text
  Color get _sliderColor => const Color(0xFFBFE8E3); // Slider active track
  Color get _sliderThumb => const Color(0xFFA9E7DF); // Lighter teal for thumbs

  @override
  void initState() {
    super.initState();
    _currentRange = RangeValues(widget.min, widget.max);
  }

  String _formatIndianCurrency(double value) {
    // Format as ₹ 10,00,000
    var text = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = text.length - 1; i >= 0; i--) {
      buffer.write(text[i]);
      count++;
      if ((i != 0) && ((count == 3) || (count > 3 && (count - 3) % 2 == 0))) {
        buffer.write(',');
      }
    }
    final formatted = buffer.toString().split('').reversed.join('');
    return '₹ $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: const [
                Text(
                  'Price Range',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: 0.2,
                  ),
                ),
                Spacer(),
                Text('-', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Pill buttons row
          Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Row(
              children: [
                _PriceInputButton(
                  label: _formatIndianCurrency(_currentRange.start),
                  bgColor: _bgColor,
                  borderColor: _borderColor,
                  textColor: _textColor,
                ),
                const SizedBox(width: 16),
                _PriceInputButton(
                  label: _formatIndianCurrency(_currentRange.end),
                  bgColor: _bgColor,
                  borderColor: _borderColor,
                  textColor: _textColor,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // RangeSlider with diamond handles
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 5,
              activeTrackColor: _sliderColor,
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: _sliderThumb,
              overlayColor: _sliderColor.withOpacity(0.25),
              rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
              rangeThumbShape: const DiamondRangeThumbShape(
                enabledThumbRadius: 13,
              ),
            ),
            child: RangeSlider(
              min: widget.min,
              max: widget.max,
              values: _currentRange,
              divisions: 10,
              onChanged: (RangeValues values) {
                setState(() => _currentRange = values);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Custom pill-shaped price button
class _PriceInputButton extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;

  const _PriceInputButton({
    required this.label,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 16.5,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
      ),
    );
  }
}

// Diamond shaped thumb for RangeSlider
class DiamondRangeThumbShape extends RangeSliderThumbShape {
  final double enabledThumbRadius;

  const DiamondRangeThumbShape({this.enabledThumbRadius = 13});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    bool isPressed = false,
    required SliderThemeData sliderTheme,
    TextDirection textDirection = TextDirection.ltr,
    Thumb thumb = Thumb.start,
  }) {
    final Canvas canvas = context.canvas;

    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.teal
      ..style = PaintingStyle.fill;

    final double r = enabledThumbRadius;

    final Path diamond = Path()
      ..moveTo(center.dx, center.dy - r) // top
      ..lineTo(center.dx + r, center.dy) // right
      ..lineTo(center.dx, center.dy + r) // bottom
      ..lineTo(center.dx - r, center.dy) // left
      ..close();

    canvas.drawPath(diamond, paint);

    // Optional: border
    final Paint borderPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawPath(diamond, borderPaint);
  }
}
