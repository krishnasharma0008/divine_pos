import 'package:flutter/material.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import '../../../../shared/utils/scale_size.dart';

class RingSizeSelector extends StatefulWidget {
  final List<String> values;
  final int initialIndex;
  final ValueChanged<String> onChanged;

  const RingSizeSelector({
    super.key,
    required this.values,
    required this.initialIndex,
    required this.onChanged,
  });

  @override
  State<RingSizeSelector> createState() => _RingSizeSelectorState();
}

class _RingSizeSelectorState extends State<RingSizeSelector> {
  late double _value;

  final Color tickColor = const Color(0xFFBEE4DD);
  final Color activeTrackColor = const Color(0xFFCFF4EE);

  int get _index => _value.round();

  @override
  void initState() {
    super.initState();
    final clamped = widget.initialIndex
        .clamp(0, widget.values.length - 1)
        .toDouble();
    _value = clamped;
  }

  @override
  void didUpdateWidget(covariant RingSizeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialIndex != widget.initialIndex) {
      final clamped = widget.initialIndex
          .clamp(0, widget.values.length - 1)
          .toDouble();

      setState(() {
        _value = clamped;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;
    final value = widget.values[_index];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * fem, vertical: 12 * fem),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDE9E5), width: 1.5),
        borderRadius: BorderRadius.circular(16 * fem),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              MyText(
                'Ring Size',
                style: TextStyle(
                  fontSize: 14 * fem,
                  fontFamily: 'Rushter Glory',
                ),
              ),
              const Spacer(),
              _buildChip(value, fem),
            ],
          ),

          SizedBox(height: 12 * fem),

          /// SIZE LABELS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _RingSizeLabels(values: widget.values, currentIndex: _index),
          ),

          SizedBox(height: 10 * fem),

          /// TRACK + TICKS + SLIDER (ALIGNED)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: SizedBox(
              height: 32 * fem,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// TICKS (aligned to track width)
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double tickHeight = 11 * fem;
                        final double trackHeight = 2 * fem;
                        final double gap = 1 * fem;

                        return Row(
                          children: List.generate(
                            widget.values.length,
                            (index) => Expanded(
                              child: Transform.translate(
                                offset: Offset(
                                  0,
                                  -(tickHeight / 2 +
                                      trackHeight / 2 +
                                      gap +
                                      10 * fem),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 2 * fem,
                                    height: tickHeight,
                                    decoration: BoxDecoration(
                                      color: index == _index
                                          ? tickColor
                                          : const Color(0xFFCFE1DD),
                                      borderRadius: BorderRadius.circular(
                                        3 * fem,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  /// Base bar
                  Container(
                    height: 6 * fem,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3 * fem),
                      border: Border.all(color: tickColor, width: 1),
                    ),
                  ),

                  /// SLIDER
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4 * fem,
                      trackShape: const RoundedRectSliderTrackShape(),
                      inactiveTrackColor: Colors.transparent,
                      activeTrackColor: activeTrackColor,
                      thumbColor: const Color(0xFFA9E7DF),
                      overlayColor: const Color(0xFFBFE8E3).withOpacity(0.25),
                      overlayShape: RoundSliderOverlayShape(
                        overlayRadius: 16 * fem,
                      ),
                      // ✅ use your diamond here
                      thumbShape: DiamondSliderThumbShape(
                        width: 10 * fem,
                        height: 15 * fem,
                      ),
                    ),
                    child: Slider(
                      min: 0,
                      max: (widget.values.length - 1).toDouble(),
                      divisions: widget.values.length - 1,
                      value: _value,
                      onChanged: (v) {
                        final newIndex = v.round();
                        if (newIndex == _index) return;

                        setState(() => _value = newIndex.toDouble());
                        widget.onChanged(widget.values[newIndex]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// VALUE CHIP
  Widget _buildChip(String text, double fem) {
    return Container(
      width: 80 * fem,
      padding: EdgeInsets.symmetric(vertical: 6 * fem),
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: const Color(0xFF90DCD0).withOpacity(0.08),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: const Color(0xFFC8AC7D), width: 0.8 * fem),
          borderRadius: BorderRadius.circular(14 * fem),
        ),
      ),
      child: MyText(
        text,
        style: TextStyle(fontSize: 14 * fem, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Labels row (uses current index via Inherited/parent if needed)
class _RingSizeLabels extends StatelessWidget {
  final List<String> values;
  final int currentIndex;

  const _RingSizeLabels({required this.values, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    return Row(
      children: List.generate(
        values.length,
        (index) => Expanded(
          child: Text(
            values[index],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10 * fem,
              fontWeight: FontWeight.w400,
              color: index == currentIndex
                  ? const Color(0xFF4A4A4A)
                  : const Color(0xFFB8C8C2),
            ),
          ),
        ),
      ),
    );
  }
}

/// 🔷 Diamond Thumb for Slider
class DiamondSliderThumbShape extends SliderComponentShape {
  final double width;
  final double height;

  const DiamondSliderThumbShape({this.width = 10, this.height = 15});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(width, height);

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
    final canvas = context.canvas;
    final paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.teal
      ..style = PaintingStyle.fill;

    final halfW = width / 2;
    final halfH = height / 2;

    final path = Path()
      ..moveTo(center.dx, center.dy - halfH)
      ..lineTo(center.dx + halfW, center.dy)
      ..lineTo(center.dx, center.dy + halfH)
      ..lineTo(center.dx - halfW, center.dy)
      ..close();

    canvas.drawPath(path, paint);
  }
}
