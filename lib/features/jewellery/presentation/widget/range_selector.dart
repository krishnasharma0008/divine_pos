import 'package:divine_pos/shared/widgets/text.dart';
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

    return Column(
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
          //SizedBox(height: 17 * fem),
        ],

        // 🔹 Price chips
        Padding(
          padding: EdgeInsets.only(left: 5 * fem),
          child: Center(
            child: Row(
              // mainAxisSize: MainAxisSize.min,
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              //spacing: 10 * fem,
              children: [
                _priceChip(formatter(values.start), fem),
                SizedBox(width: 7 * fem),
                MyText(
                  '-',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF4A4A4A),
                    fontSize: 12,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),

                SizedBox(width: 11 * fem),
                _priceChip(formatter(values.end), fem),
              ],
            ),
          ),
        ),

        //SizedBox(height: 5 * fem),

        // 🔹 Range Slider
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4, // use larger height (Flutter limitation)
            inactiveTrackColor: const Color(0xFFF1F1F1),
            activeTrackColor: const Color(0xFFD0F5EE),
            thumbColor: const Color(0xFFA9E7DF),
            overlayColor: const Color(0xFFBFE8E3).withValues(alpha: 0.25),
            rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
            rangeThumbShape: DiamondRangeThumbShape(
              width: 10 * fem,
              height: 15 * fem,
            ),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 16 * fem),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 5 * fem),
            child: SizedBox(
              width: 240 * fem, // 🎯 fixed Figma width
              child: RangeSlider(
                min: min,
                max: max,
                values: values,
                divisions: 12,
                onChanged: onChanged,
              ),
            ),
          ),

          // child: RangeSlider(
          //   min: min,
          //   max: max,
          //   values: values,
          //   divisions: 12,
          //   onChanged: onChanged,
          // ),
        ),
      ],
    );
  }

  // 🔹 Price chip widget
  Widget _priceChip(String text, double fem) {
    return Container(
      width: 114 * fem,
      padding: EdgeInsets.all(10 * fem),
      decoration: ShapeDecoration(
        color: const Color(0xFF90DCD0).withOpacity(0.11), // 0x1C = 11%
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1 * fem, color: const Color(0xFFC8AC7D)),
          borderRadius: BorderRadius.circular(15 * fem),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3FC5C5C5),
            blurRadius: 4,
            offset: Offset(2, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: MyText(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF4A4A4A),
          fontSize: 14 * fem,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
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
