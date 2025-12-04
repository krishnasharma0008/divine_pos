import 'package:flutter/material.dart';

class RangeSelector extends StatefulWidget {
  final double min;
  final double max;
  final String title;
  final String Function(double value) formatter;

  // new: notify parent when range changes
  final ValueChanged<RangeValues>? onChanged;

  const RangeSelector({
    super.key,
    required this.min,
    required this.max,
    this.title = '',
    this.formatter = _defaultIndianFormatter,
    this.onChanged,
  });

  // default Indian currency formatter
  static String _defaultIndianFormatter(double value) {
    String s = value.toStringAsFixed(0);
    int n = s.length;
    if (n <= 3) return "₹ $s";

    String last3 = s.substring(n - 3);
    String rest = s.substring(0, n - 3);

    final buf = StringBuffer();
    int counter = 0;
    for (int i = rest.length - 1; i >= 0; i--) {
      buf.write(rest[i]);
      counter++;
      if (counter % 2 == 0 && i != 0) buf.write(",");
    }

    String formattedRest = buf.toString().split('').reversed.join('');
    return "₹ $formattedRest,$last3";
  }

  @override
  State<RangeSelector> createState() => _RangeSelectorState();
}

class _RangeSelectorState extends State<RangeSelector> {
  late RangeValues _range;

  final _borderColor = const Color(0xFFD9C6A3);
  final _bgColor = const Color(0xFFEAF9F5);
  final _textColor = const Color(0xFF20706F);
  final _sliderColor = const Color(0xFFBFE8E3);
  final _sliderThumb = const Color(0xFFA9E7DF);

  @override
  void initState() {
    super.initState();
    _range = RangeValues(widget.min, widget.max);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasTitle = widget.title.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          if (hasTitle) ...[
            Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                //const Icon(Icons.keyboard_arrow_up_rounded, size: 20),
              ],
            ),

            const SizedBox(height: 14),
          ],
          // Start / End value buttons
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                _priceChip(widget.formatter(_range.start)),
                const SizedBox(width: 20),
                _priceChip(widget.formatter(_range.end)),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Slider
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
              values: _range,
              divisions: 12,
              onChanged: (values) {
                setState(() => _range = values);
                widget.onChanged?.call(
                  values,
                ); // ← send selected range to parent
              },
              // onChanged: (values) {
              //   setState(() => _range = values);
              // },
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceChip(String text) {
    return SizedBox(
      width: 135, // fixed width you want
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          //color: _bgColor,
          color: Color(0xFFF3FBFA),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _borderColor, width: 1.2),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// Diamond thumb shape for slider
class DiamondRangeThumbShape extends RangeSliderThumbShape {
  final double enabledThumbRadius;

  const DiamondRangeThumbShape({this.enabledThumbRadius = 13});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(enabledThumbRadius);

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
    final canvas = context.canvas;

    final paint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    final r = enabledThumbRadius;

    final diamond = Path()
      ..moveTo(center.dx, center.dy - r)
      ..lineTo(center.dx + r, center.dy)
      ..lineTo(center.dx, center.dy + r)
      ..lineTo(center.dx - r, center.dy)
      ..close();

    canvas.drawPath(diamond, paint);
  }
}
