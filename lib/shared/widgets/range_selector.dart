import 'package:flutter/material.dart';
import '../../../../shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart';

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
    // _range = RangeValues(
    //   widget.initialStartIndex.toDouble(),
    //   widget.initialEndIndex.toDouble(),
    // );
    _range = RangeValues(
      widget.initialStartIndex.clamp(0, widget.values.length - 1).toDouble(),
      widget.initialEndIndex.clamp(0, widget.values.length - 1).toDouble(),
    );
  }

  // ✅ THIS MUST BE HERE
  @override
  void didUpdateWidget(covariant RangeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialStartIndex != widget.initialStartIndex ||
        oldWidget.initialEndIndex != widget.initialEndIndex) {
      setState(() {
        _range = RangeValues(
          widget.initialStartIndex.toDouble(),
          widget.initialEndIndex.toDouble(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;
    final String startValue = widget.values[_startIndex];
    final String endValue = widget.values[_endIndex];
    final chipFormatter = widget.valueToChipText ?? (String v) => v;

    /// 🎯 EXACT thumb radius used by slider
    final double thumbRadius = (10 * fem) / 2;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * fem, vertical: 10 * fem),
      decoration: BoxDecoration(
        color: Colors.white,
        //border: Border.all(color: const Color(0xFFDDE9E5), width: 1.5),
        border: Border.all(color: Colors.transparent, width: 1.5),
        borderRadius: BorderRadius.circular(16 * fem),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Label
          // Padding(
          //   padding: EdgeInsets.only(left: 8 * fem),
          //   child: MyText(
          //     widget.label,

          //     // style: TextStyle(
          //     //   color: const Color(0xFF303030),
          //     //   fontSize: 14 * fem,
          //     //   fontWeight: FontWeight.w400,
          //     // ),
          //     style: TextStyle(
          //       color: Color(0xFF303030),
          //       fontSize: 14 * fem,
          //       fontFamily: 'Rushter Glory',
          //       fontWeight: FontWeight.w400,
          //     ),
          //   ),
          // ),

          // SizedBox(height: 8 * fem),

          // /// Chips
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     _buildValueChip(chipFormatter(startValue), fem),
          //     SizedBox(width: 6 * fem),
          //     const Text('-'),
          //     SizedBox(width: 6 * fem),
          //     _buildValueChip(chipFormatter(endValue), fem),
          //   ],
          // ),

          /// HEADER
          Row(
            children: [
              MyText(
                widget.label,
                style: TextStyle(
                  fontSize: 14 * fem,
                  fontFamily: 'Rushter Glory',
                ),
              ),
              const Spacer(),

              /// VALUE CHIP
              _buildValueChip(chipFormatter(startValue), fem),
              SizedBox(width: 6 * fem),
              const Text('-'),
              SizedBox(width: 6 * fem),
              _buildValueChip(chipFormatter(endValue), fem),
            ],
          ),

          SizedBox(height: 18 * fem),

          /// LABELS — PERFECTLY MATCH SLIDER DOTS
          Padding(
            padding: EdgeInsets.symmetric(horizontal: thumbRadius),
            child: Row(
              children: List.generate(
                widget.values.length,
                (index) => Expanded(
                  child: Text(
                    widget.values[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11 * fem,
                      fontWeight: FontWeight.w500,
                      color: (index >= _startIndex && index <= _endIndex)
                          ? Colors.black
                          : const Color(0xFFD9D9D9),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 10 * fem),

          /// TICKS — MATCH LABELS & SLIDER
          Padding(
            padding: EdgeInsets.symmetric(horizontal: thumbRadius),
            child: Row(
              children: List.generate(
                widget.values.length,
                (index) => Expanded(
                  child: Center(
                    child: Container(
                      width: 3 * fem,
                      height: 11 * fem,
                      decoration: BoxDecoration(
                        color: (index >= _startIndex && index <= _endIndex)
                            ? tickColor
                            : const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(1.5 * fem),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 10 * fem),

          /// TRACK + SLIDER — SAME GEOMETRY
          Padding(
            padding: EdgeInsets.symmetric(horizontal: thumbRadius),
            child: Stack(
              alignment: Alignment.center,
              children: [
                /// Base bar
                Container(
                  height: 6 * fem,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3 * fem),
                    border: Border.all(color: tickColor, width: 1),
                  ),
                ),

                /// Slider
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4 * fem,
                    inactiveTrackColor: Colors.transparent,
                    activeTrackColor: activeTrackColor,
                    thumbColor: const Color(0xFFA9E7DF),
                    overlayColor: const Color(0xFFBFE8E3).withOpacity(0.25),
                    rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
                    rangeThumbShape: DiamondRangeThumbShape(
                      width: 10 * fem,
                      height: 15 * fem,
                    ),
                    overlayShape: RoundSliderOverlayShape(
                      overlayRadius: 16 * fem,
                    ),
                  ),
                  child: RangeSlider(
                    min: 0,
                    max: (widget.values.length - 1).toDouble(),
                    divisions: widget.values.length - 1,
                    values: _range,
                    // onChanged: (v) {
                    //   setState(() {
                    //     _range = RangeValues(
                    //       v.start.roundToDouble(),
                    //       v.end.roundToDouble(),
                    //     );
                    //   });
                    //   widget.onRangeChanged(
                    //     widget.values[_startIndex],
                    //     widget.values[_endIndex],
                    //   );
                    // },
                    onChanged: (v) {
                      final start = v.start.round();
                      final end = v.end.round();

                      setState(() {
                        _range = RangeValues(start.toDouble(), end.toDouble());
                      });

                      widget.onRangeChanged(
                        widget.values[start],
                        widget.values[end],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueChip(String text, double fem) {
    return Container(
      width: 114 * fem,
      padding: EdgeInsets.all(10 * fem),
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: const Color(0xFF90DCD0).withOpacity(0.11),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: const Color(0xFFC8AC7D), width: 1 * fem),
          borderRadius: BorderRadius.circular(15 * fem),
        ),
      ),
      child: MyText(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14 * fem,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF4A4A4A),
        ),
      ),
    );
  }
}

/// 🔷 Diamond Thumb
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
    required SliderThemeData sliderTheme,
    Thumb thumb = Thumb.start,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = true,
    bool isPressed = false,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final canvas = context.canvas;
    final paint = Paint()
      ..color = sliderTheme.thumbColor!
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
