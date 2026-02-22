import 'package:flutter/material.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import '../../../../shared/utils/scale_size.dart';

class ColorClarityRangeSlider extends StatefulWidget {
  final String title;
  final List<String> options;
  final int initialStartIndex;
  final int initialEndIndex;
  final ValueChanged<RangeValues>? onChanged;
  final VoidCallback? onDismiss;

  const ColorClarityRangeSlider({
    super.key,
    required this.title,
    required this.options,
    this.initialStartIndex = 0,
    required this.initialEndIndex,
    this.onChanged,
    this.onDismiss,
  });

  @override
  State<ColorClarityRangeSlider> createState() =>
      _ColorClarityRangeSliderState();
}

class _ColorClarityRangeSliderState extends State<ColorClarityRangeSlider> {
  late double startIndex;
  late double endIndex;

  @override
  void initState() {
    super.initState();
    startIndex = widget.initialStartIndex.toDouble();
    endIndex = widget.initialEndIndex.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio.clamp(0.7, 1.3);
    final int start = startIndex.toInt();
    final int end = endIndex.toInt();
    final int count = widget.options.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
        if (widget.title.trim().isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(
                widget.title,
                style: TextStyle(
                  fontSize: 16 * fem,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF3A3A3A),
                ),
              ),
              if (widget.onDismiss != null)
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: Text(
                    '−',
                    style: TextStyle(
                      fontSize: 24 * fem,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFFAAAAAA),
                      height: 1,
                    ),
                  ),
                ),
            ],
          ),

        SizedBox(height: 14 * fem),

        /// PILLS ROW
        Row(
          children: [
            Expanded(child: _valueBox(widget.options[start], fem)),
            SizedBox(
              width: 28 * fem,
              child: Text(
                '-',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16 * fem,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFAAAAAA),
                ),
              ),
            ),
            Expanded(child: _valueBox(widget.options[end], fem)),
          ],
        ),

        SizedBox(height: 16 * fem),

        /// RANGE SLIDER + TICK MARKS
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            inactiveTrackColor: const Color(0xFFEFEFEF),
            activeTrackColor: const Color(0xFFCAEEE7),
            overlayColor: const Color(0xFFC8AC7D).withOpacity(0.15),
            rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
            rangeThumbShape: DiamondRangeThumbShape(
              width: 12 * fem,
              height: 12 * fem,
            ),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 14 * fem),
          ),
          child: RangeSlider(
            min: 0,
            max: (count - 1).toDouble(),
            divisions: count - 1,
            values: RangeValues(startIndex, endIndex),
            onChanged: (values) {
              setState(() {
                startIndex = values.start.roundToDouble();
                endIndex = values.end.roundToDouble();
                widget.onChanged?.call(values);
              });
            },
          ),
        ),

        /// TICK MARKS + LABELS
        LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;
            // Flutter's RangeSlider has ~24px padding on each side for the thumb overlay
            const horizontalPadding = 24.0;
            final usableWidth = trackWidth - horizontalPadding * 2;

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Column(
                children: [
                  // Tick marks
                  SizedBox(
                    height: 10 * fem,
                    child: Stack(
                      children: List.generate(count, (i) {
                        final inRange = i >= start && i <= end;
                        final left = (i / (count - 1)) * usableWidth - 2;
                        return Positioned(
                          left: left,
                          child: Container(
                            width: 4 * fem,
                            height: inRange ? 10 * fem : 7 * fem,
                            decoration: BoxDecoration(
                              color: inRange
                                  ? const Color(0xFF7DCEC3)
                                  : const Color(0xFFD5D5D5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  SizedBox(height: 6 * fem),

                  // Labels
                  Row(
                    children: List.generate(count, (i) {
                      final isEndpoint = i == start || i == end;
                      return Expanded(
                        child: MyText(
                          widget.options[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10 * fem,
                            fontWeight: isEndpoint
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isEndpoint
                                ? const Color(0xFF1A1A1A)
                                : const Color(0xFFB8B8B8),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// VALUE BOX
  Widget _valueBox(String text, double fem) {
    return SizedBox(
      width: 114 * fem,
      child: Container(
        //padding: EdgeInsets.symmetric(horizontal: 16 * fem, vertical: 12 * fem),
        padding: EdgeInsets.all(10 * fem),
        decoration: BoxDecoration(
          color: const Color(0xFFF3FBFA),
          borderRadius: BorderRadius.circular(15 * fem),
          border: Border.all(color: const Color(0xFFE5C289), width: 1 * fem),
        ),
        alignment: Alignment.center,
        child: MyText(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14 * fem, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// Diamond-shaped thumb for RangeSlider
class DiamondRangeThumbShape extends RangeSliderThumbShape {
  final double width;
  final double height;

  const DiamondRangeThumbShape({this.width = 10, this.height = 15});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(width, height);

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
