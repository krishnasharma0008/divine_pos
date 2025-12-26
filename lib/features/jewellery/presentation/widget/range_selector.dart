import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import '../../../../shared/utils/scale_size.dart';
import '../../../../shared/widgets/text.dart';

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

  // 🇮🇳 Indian currency formatter
  static String _defaultIndianFormatter(double value) {
    final s = value.toStringAsFixed(0);
    final n = s.length;
    if (n <= 3) return "₹ $s";

    final last3 = s.substring(n - 3);
    final rest = s.substring(0, n - 3);

    final buf = StringBuffer();
    int counter = 0;
    for (int i = rest.length - 1; i >= 0; i--) {
      buf.write(rest[i]);
      counter++;
      if (counter % 2 == 0 && i != 0) buf.write(",");
    }

    final formattedRest = buf.toString().split('').reversed.join();
    return "₹ $formattedRest,$last3";
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;
    final hasTitle = title.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12 * fem),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Title
          if (hasTitle) ...[
            Row(
              children: [
                MyText(
                  title,
                  style: TextStyle(
                    fontSize: 16 * fem,
                    fontWeight: FontWeight.w400, // matches Figma
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
              ],
            ),
            SizedBox(height: 14 * fem),
          ],

          // 🔹 Price chips
          Padding(
            padding: EdgeInsets.only(left: 12 * fem),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _priceChip(formatter(values.start), fem),
                SizedBox(width: 10 * fem),
                MyText(
                  '–',
                  style: TextStyle(
                    fontSize: 20 * fem,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 10 * fem),
                _priceChip(formatter(values.end), fem),
              ],
            ),
          ),

          SizedBox(height: 10 * fem),

          // 🔹 Range Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3, // use larger height (Flutter limitation)
              inactiveTrackColor: const Color(0xFFF1F1F1),
              activeTrackColor: const Color(0xFFD0F5EE),
              thumbColor: const Color(0xFFA9E7DF),
              overlayColor: const Color(0xFFBFE8E3).withOpacity(0.25),
              rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
              rangeThumbShape: DiamondRangeThumbShape(
                width: 10 * fem,
                height: 15 * fem,
              ),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 16 * fem),
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

  // 🔹 Price chip widget
  Widget _priceChip(String text, double fem) {
    return SizedBox(
      width: 114 * fem,
      child: Container(
        padding: EdgeInsets.all(10 * fem),
        decoration: BoxDecoration(
          color: const Color(0x1C90DCD0),
          borderRadius: BorderRadius.circular(15 * fem),
          border: Border.all(color: const Color(0xFFC8AC7D), width: 1 * fem),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3FC5C5C5),
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: MyText(
          text,
          style: TextStyle(
            fontSize: 14 * fem,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4A4A4A),
          ),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
/// Diamond Range Thumb Shape
///////////////////////////////////////////////////////////////////////////////

class DiamondRangeThumbShape extends RangeSliderThumbShape {
  final double width;
  final double height;

  const DiamondRangeThumbShape({this.width = 10, this.height = 15});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(width, height);
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
    final canvas = context.canvas;

    final paint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    final halfW = width / 2;
    final halfH = height / 2;

    final path = Path()
      ..moveTo(center.dx, center.dy - halfH) // top
      ..lineTo(center.dx + halfW, center.dy) // right
      ..lineTo(center.dx, center.dy + halfH) // bottom
      ..lineTo(center.dx - halfW, center.dy) // left
      ..close();

    canvas.drawPath(path, paint);
  }
}
