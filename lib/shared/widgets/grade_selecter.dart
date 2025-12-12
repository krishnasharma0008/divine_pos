import 'package:flutter/material.dart';

// Diamond handle thumb shape for the slider
class DiamondSliderThumbShape extends SliderComponentShape {
  final double thumbRadius;
  const DiamondSliderThumbShape({this.thumbRadius = 12});
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(thumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required Size sizeWithOverflow,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double textScaleFactor,
    required double value,
  }) {
    final Canvas canvas = context.canvas;
    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.teal
      ..style = PaintingStyle.fill;

    final double r = thumbRadius;
    final Path diamond = Path()
      ..moveTo(center.dx, center.dy - r)
      ..lineTo(center.dx + r, center.dy)
      ..lineTo(center.dx, center.dy + r)
      ..lineTo(center.dx - r, center.dy)
      ..close();

    canvas.drawPath(diamond, paint);
    // Border for diamond
    final Paint borderPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(diamond, borderPaint);
  }
}

class ColorGradeSelector extends StatefulWidget {
  final String label;
  final List<String> grades;
  final ValueChanged<String> onSelected;
  final String initialValue;

  const ColorGradeSelector({
    super.key,
    required this.label,
    required this.grades,
    required this.onSelected,
    required this.initialValue,
  });

  @override
  State<ColorGradeSelector> createState() => _ColorGradeSelectorState();
}

class _ColorGradeSelectorState extends State<ColorGradeSelector> {
  late double _sliderValue;

  final tickColor = const Color(0xFFBFE8E3);

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.grades
        .indexOf(widget.initialValue)
        .toDouble()
        .clamp(0, (widget.grades.length - 1).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(22),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFDDE9E5), width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),

            /// ✅ LABELS + TICKS
            Row(
              children: List.generate(
                widget.grades.length,
                (index) => Expanded(
                  child: Column(
                    children: [
                      Text(
                        widget.grades[index],
                        style: TextStyle(
                          fontSize: 15,
                          color: (index == _sliderValue.round())
                              ? Colors.teal
                              : Colors.black87,
                          fontWeight: (index == _sliderValue.round())
                              ? FontWeight.bold
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 4,
                        height: 12,
                        decoration: BoxDecoration(
                          color: tickColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// ✅ SLIDER
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 8,
                activeTrackColor: tickColor,
                inactiveTrackColor: Colors.grey.shade200,
                thumbColor: tickColor,
                thumbShape: const DiamondSliderThumbShape(thumbRadius: 14),
                overlayColor: tickColor.withOpacity(0.21),
              ),
              child: Slider(
                min: 0,
                max: (widget.grades.length - 1).toDouble(),
                divisions: widget.grades.length - 1,
                value: _sliderValue,
                onChanged: (value) {
                  setState(() => _sliderValue = value);
                  widget.onSelected(widget.grades[value.round()]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
