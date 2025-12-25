import 'package:flutter/material.dart';

class RangeSelector extends StatefulWidget {
  final String label;
  final List<String> values;
  final int initialStartIndex;
  final int initialEndIndex;
  final void Function(String start, String end) onRangeChanged;
  final String Function(String value)? valueToChipText;

  const RangeSelector({
    super.key,
    required this.label,
    required this.values,
    required this.initialStartIndex,
    required this.initialEndIndex,
    required this.onRangeChanged,
    this.valueToChipText,
  });

  @override
  State<RangeSelector> createState() => _RangeSelectorState();
}

class _RangeSelectorState extends State<RangeSelector> {
  late RangeValues _range;
  final Color tickColor = const Color(0xFFBEE4DD);
  final Color activeTrackColor = const Color(0xFFCFF4EE);

  int get _startIndex => _range.start.round();
  int get _endIndex => _range.end.round();

  @override
  void initState() {
    super.initState();
    _range = RangeValues(
      widget.initialStartIndex.toDouble(),
      widget.initialEndIndex.toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String startValue = widget.values[_startIndex];
    final String endValue = widget.values[_endIndex];
    final chipFormatter = widget.valueToChipText ?? (String v) => v;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDDE9E5), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              widget.label,

              //style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              style: TextStyle(
                color: const Color(0xFF303030),
                fontSize: 14,
                fontFamily: 'Rushter Glory',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildValueChip(chipFormatter(startValue)),
              const SizedBox(width: 6),
              const Text('-'),
              const SizedBox(width: 6),
              _buildValueChip(chipFormatter(endValue)),
            ],
          ),
          const SizedBox(height: 10),

          // Labels row
          Row(
            children: List.generate(
              widget.values.length,
              (index) => Expanded(
                child: Text(
                  widget.values[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: (index >= _startIndex && index <= _endIndex)
                        ? Colors.black
                        : const Color(0xFFD9D9D9), // non-selected
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Ticks row
          Row(
            children: List.generate(
              widget.values.length,
              (index) => Expanded(
                child: Center(
                  child: Container(
                    width: 3,
                    height: 11,
                    decoration: BoxDecoration(
                      color: (index >= _startIndex && index <= _endIndex)
                          ? tickColor
                          : const Color(0xFFD9D9D9), // non-selected tick
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Track + slider
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: tickColor, width: 1),
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  activeTrackColor: activeTrackColor,
                  inactiveTrackColor: Colors.transparent,
                  // inactiveTrackColor: const Color(
                  //   0xFFD9D9D9,
                  // ), // non-selected range
                  thumbColor: activeTrackColor,
                  overlayColor: activeTrackColor.withOpacity(0.25),
                  rangeThumbShape: const DiamondRangeThumbShape(
                    thumbRadius: 11,
                  ),
                ),
                child: RangeSlider(
                  min: 0,
                  max: (widget.values.length - 1).toDouble(),
                  divisions: widget.values.length - 1,
                  values: _range,
                  onChanged: (v) {
                    setState(() {
                      _range = RangeValues(
                        v.start.roundToDouble(),
                        v.end.roundToDouble(),
                      );
                    });
                    widget.onRangeChanged(
                      widget.values[_startIndex],
                      widget.values[_endIndex],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x1C90DCD0),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFC8AC7D)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Color(0xFF4A4A4A)),
      ),
    );
  }
}

/// Diamond thumb
class DiamondRangeThumbShape extends RangeSliderThumbShape {
  final double thumbRadius;

  const DiamondRangeThumbShape({this.thumbRadius = 12});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(thumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    TextDirection? textDirection,
    required SliderThemeData sliderTheme,
    Thumb? thumb,
    bool isPressed = false,
  }) {
    final Canvas canvas = context.canvas;

    final Paint fillPaint = Paint()
      ..color = sliderTheme.thumbColor ?? const Color(0xFFCFF4EE)
      ..style = PaintingStyle.fill;

    final double r = thumbRadius;

    final Path diamond = Path()
      ..moveTo(center.dx, center.dy - r)
      ..lineTo(center.dx + r, center.dy)
      ..lineTo(center.dx, center.dy + r)
      ..lineTo(center.dx - r, center.dy)
      ..close();

    canvas.drawPath(diamond, fillPaint);

    final Paint borderPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(diamond, borderPaint);
  }
}
