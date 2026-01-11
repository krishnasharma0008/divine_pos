import 'package:flutter/material.dart';
import '../../../../shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart';

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
  late RangeValues _range;

  final Color tickColor = const Color(0xFFBEE4DD);
  final Color activeTrackColor = const Color(0xFFCFF4EE);

  int get _index => _range.start.round();

  @override
  void initState() {
    super.initState();
    _range = RangeValues(
      widget.initialIndex.toDouble(),
      widget.initialIndex.toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;
    final value = widget.values[_index];

    final double thumbRadius = (10 * fem) / 2;

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

              /// VALUE CHIP
              _buildChip(value, fem),
            ],
          ),

          SizedBox(height: 18 * fem),

          /// SIZE LABELS
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
                      color: index == _index
                          ? Colors.black
                          : const Color(0xFFD9D9D9),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 10 * fem),

          /// TICKS
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
                        color: index == _index
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

          /// SLIDER
          Padding(
            padding: EdgeInsets.symmetric(horizontal: thumbRadius),
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4 * fem,
                activeTrackColor: activeTrackColor,
                inactiveTrackColor: Colors.transparent,
                thumbColor: const Color(0xFFA9E7DF),
                overlayColor: const Color(0xFFBFE8E3).withOpacity(0.25),
                rangeThumbShape: DiamondRangeThumbShape(
                  width: 10 * fem,
                  height: 15 * fem,
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
                      v.start.roundToDouble(),
                    );
                  });
                  widget.onChanged(widget.values[_index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text, double fem) {
    return Container(
      width: 80 * fem,
      padding: EdgeInsets.symmetric(vertical: 8 * fem),
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: const Color(0xFF90DCD0).withOpacity(0.11),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: const Color(0xFFC8AC7D), width: 1 * fem),
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
