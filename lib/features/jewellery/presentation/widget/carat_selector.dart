import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import '../../../../shared/utils/scale_size.dart';

class CaratSelector extends StatelessWidget {
  final RangeValues values;
  final ValueChanged<RangeValues>? onChanged;
  final List<String> caratOptions; // Your _caratOptions

  const CaratSelector({
    super.key,
    required this.values,
    this.onChanged,
    this.caratOptions = const [
      '0.10',
      '0.14',
      '0.18',
      '0.25',
      '0.50',
      '0.75',
      '1.00',
      '1.50',
      '2.00',
      '2.50',
      '2.99',
    ],
  });

  List<double> get _caratDoubles =>
      caratOptions.map((c) => double.parse(c)).toList();
  double get minCarat => _caratDoubles.first;
  double get maxCarat => _caratDoubles.last;

  String _formatCarat(double value) => '${value.toStringAsFixed(2)} ct';

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          'Carat',
          style: TextStyle(fontSize: 16 * fem, fontWeight: FontWeight.w400),
        ),

        SizedBox(height: 12 * fem),

        // 🔹 Preset chips row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5 * fem),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final chipWidth = constraints.maxWidth / 6; // Responsive chips
              return Wrap(
                spacing: 6 * fem,
                runSpacing: 8 * fem,
                children: caratOptions.map((carat) {
                  final value = double.parse(carat);
                  final isSelected =
                      values.start <= value && value <= values.end;
                  return GestureDetector(
                    onTap: () => onChanged?.call(RangeValues(value, value)),
                    child: Container(
                      width: chipWidth,
                      padding: EdgeInsets.symmetric(vertical: 8 * fem),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4A90E2)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20 * fem),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey[300]!,
                          width: 1 * fem,
                        ),
                      ),
                      child: MyText(
                        _formatCarat(value),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF4A4A4A),
                          fontSize: 12 * fem,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),

        SizedBox(height: 16 * fem),

        // 🔹 Range slider (reuse your theme)
        LayoutBuilder(
          builder: (context, constraints) => SliderTheme(
            data: SliderThemeData(
              trackHeight: 4 * fem,
              inactiveTrackColor: Colors.grey[300],
              activeTrackColor: const Color(0xFF4A90E2),
              thumbColor: const Color(0xFF63B3ED),
              rangeThumbShape: DiamondRangeThumbShape(
                width: 12 * fem,
                height: 16 * fem,
              ),
              overlayColor: const Color(0xFF63B3ED).withOpacity(0.25),
            ),
            child: RangeSlider(
              min: minCarat,
              max: maxCarat,
              values: values,
              divisions: caratOptions.length - 1,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
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
