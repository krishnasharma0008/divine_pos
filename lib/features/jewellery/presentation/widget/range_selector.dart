import 'package:flutter/material.dart';
import '../../../../shared/utils/scale_size.dart';

class RangeSelector extends StatelessWidget {
  final double min;
  final double max;
  final String title;
  final String Function(double value) formatter;
  final ValueChanged<RangeValues>? onChanged;
  final RangeValues values;

  const RangeSelector({
    super.key,
    required this.min,
    required this.max,
    this.title = '',
    this.formatter = _defaultIndianFormatter,
    this.onChanged,
    required this.values,
  });

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
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;
    final bool hasTitle = title.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12 * fem, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasTitle) ...[
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16 * fem,
                  ),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 14 * fem),
          ],
          Padding(
            padding: EdgeInsets.only(left: 12 * fem),
            child: Row(
              children: [
                _priceChip(formatter(values.start), fem),
                SizedBox(width: 10 * fem),
                _priceChip(formatter(values.end), fem),
              ],
            ),
          ),
          SizedBox(height: 10 * fem),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 5,
              activeTrackColor: Color(0xFFBFE8E3),
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: Color(0xFFA9E7DF),
              overlayColor: Color(0xFFBFE8E3).withOpacity(0.25),
              rangeTrackShape: RoundedRectRangeSliderTrackShape(),
              rangeThumbShape: DiamondRangeThumbShape(enabledThumbRadius: 13),
            ),
            child: RangeSlider(
              min: min,
              max: max,
              values: values,
              divisions: 12,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceChip(String text, double fem) {
    return SizedBox(
      width: 135 * fem,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 22 * fem, vertical: 10 * fem),
        decoration: BoxDecoration(
          color: Color(0xFFF3FBFA),
          borderRadius: BorderRadius.circular(15 * fem),
          border: Border.all(color: Color(0xFFD9C6A3), width: 1.2 * fem),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14 * fem,
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
