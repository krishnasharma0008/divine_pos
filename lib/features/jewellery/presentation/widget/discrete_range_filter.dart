import 'package:flutter/material.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import '../../../../shared/utils/scale_size.dart';

class DiscreteRangeSlider extends StatefulWidget {
  final String title;
  final List<String> options;
  final int initialStartIndex;
  final int initialEndIndex;
  final ValueChanged<RangeValues>? onChanged;
  final bool showlabels;

  const DiscreteRangeSlider({
    super.key,
    required this.title,
    required this.options,
    this.initialStartIndex = 0,
    required this.initialEndIndex,
    this.onChanged,
    this.showlabels = true,
  });

  @override
  State<DiscreteRangeSlider> createState() => _DiscreteRangeSliderState();
}

class _DiscreteRangeSliderState extends State<DiscreteRangeSlider> {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title.trim().isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 8 * fem),
            child: MyText(
              widget.title,
              style: TextStyle(fontSize: 16 * fem, fontWeight: FontWeight.w400),
            ),
          ),

        /// SELECTED VALUES
        Padding(
          padding: EdgeInsets.only(left: 5 * fem),
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _valueBox(widget.options[startIndex.toInt()], fem),

              SizedBox(width: 12 * fem),

              Text(
                "-",
                style: TextStyle(
                  fontSize: 12 * fem,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF4B4B4B),
                ),
              ),

              SizedBox(width: 12 * fem),

              _valueBox(widget.options[endIndex.toInt()], fem),
            ],
          ),
        ),

        SizedBox(height: 12 * fem),

        /// RANGE SLIDER
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
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
            min: 0,
            max: (widget.options.length - 1).toDouble(),
            divisions: widget.options.length - 1,
            values: RangeValues(startIndex, endIndex),
            // labels: RangeLabels(
            //   widget.options[startIndex.toInt()],
            //   widget.options[endIndex.toInt()],
            // ),
            onChanged: (values) {
              setState(() {
                startIndex = values.start.roundToDouble();
                endIndex = values.end.roundToDouble();
                widget.onChanged?.call(values);
              });
            },
          ),
        ),
        SizedBox(height: 4 * fem),

        if (widget.showlabels) ...[
          SizedBox(height: 4 * fem),
          _buildTicksAndLabels(fem),
        ],
      ],
    );
  }

  Widget _buildTicksAndLabels(double fem) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10 * fem),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(widget.options.length, (index) {
          final isSelected =
              index == startIndex.toInt() || index == endIndex.toInt();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // छोटा tick
              Container(
                width: 2 * fem,
                height: 8 * fem,
                decoration: BoxDecoration(
                  color: const Color(0xFFA9E7DF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 4 * fem),
              // label (start/end bold)
              Text(
                widget.options[index],
                style: TextStyle(
                  fontSize: 10 * fem,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.black : const Color(0xFF4B4B4B),
                ),
              ),
            ],
          );
        }),
      ),
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

/// Diamond-shaped thumb for RangeSlider
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
