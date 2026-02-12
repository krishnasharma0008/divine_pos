import 'package:flutter/material.dart';
import '../../../../shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart';

class CaratRangeSelector extends StatefulWidget {
  final String label;
  final List<String> values;
  final int initialStartIndex;
  final int initialEndIndex;
  final void Function(String start, String end) onRangeChanged;
  final String Function(String value)? valueToChipText;

  const CaratRangeSelector({
    super.key,
    required this.label,
    required this.values,
    required this.initialStartIndex,
    required this.initialEndIndex,
    required this.onRangeChanged,
    this.valueToChipText,
  });

  @override
  State<CaratRangeSelector> createState() => _CaratRangeSelectorState();
}

class _CaratRangeSelectorState extends State<CaratRangeSelector> {
  late RangeValues _range;
  final ScrollController _scrollController = ScrollController();
  bool _showArrows = false;

  final Color tickColor = const Color(0xFFBEE4DD);
  final Color activeTrackColor = const Color(0xFFCFF4EE);

  int get _startIndex => _range.start.round();
  int get _endIndex => _range.end.round();

  @override
  void initState() {
    super.initState();
    _range = RangeValues(
      widget.initialStartIndex.clamp(0, widget.values.length - 1).toDouble(),
      widget.initialEndIndex.clamp(0, widget.values.length - 1).toDouble(),
    );

    // Check if scrolling is needed after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfScrollNeeded();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CaratRangeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only update if values list actually changed
    if (oldWidget.values != widget.values) {
      setState(() {
        _range = RangeValues(
          widget.initialStartIndex
              .clamp(0, widget.values.length - 1)
              .toDouble(),
          widget.initialEndIndex.clamp(0, widget.values.length - 1).toDouble(),
        );
      });

      // Recheck scroll after values change
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkIfScrollNeeded();
      });
    }
  }

  void _checkIfScrollNeeded() {
    if (!mounted || !_scrollController.hasClients) return;

    // Check if content width exceeds viewport width
    final hasOverflow = _scrollController.position.maxScrollExtent > 0;

    if (hasOverflow != _showArrows) {
      setState(() {
        _showArrows = hasOverflow;
      });
    }
  }

  void _scrollLeft() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      (_scrollController.offset - 150).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      (_scrollController.offset + 150).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
        border: Border.all(color: Colors.transparent, width: 1.5),
        borderRadius: BorderRadius.circular(16 * fem),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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

          /// SCROLLABLE SECTION WITH ARROWS
          Row(
            children: [
              /// LEFT ARROW (conditional)
              if (_showArrows) ...[
                InkWell(
                  onTap: _scrollLeft,
                  child: Container(
                    width: 30 * fem,
                    height: 30 * fem,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF90DCD0).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8 * fem),
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      size: 20 * fem,
                      color: const Color(0xFF90DCD0),
                    ),
                  ),
                ),
                SizedBox(width: 8 * fem),
              ],

              /// ENTIRE SCROLLABLE CONTENT (labels + ticks + slider)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    final itemWidth = 50 * fem;
                    final calculatedWidth = widget.values.length * itemWidth;

                    // Use available width if content is smaller, otherwise use calculated
                    final needsScroll = calculatedWidth > availableWidth;

                    return SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: needsScroll
                          ? null
                          : const NeverScrollableScrollPhysics(),
                      child: SizedBox(
                        width: needsScroll ? calculatedWidth : availableWidth,
                        child: _buildContent(
                          fem,
                          thumbRadius,
                          needsScroll,
                          itemWidth,
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// RIGHT ARROW (conditional)
              if (_showArrows) ...[
                SizedBox(width: 8 * fem),
                InkWell(
                  onTap: _scrollRight,
                  child: Container(
                    width: 30 * fem,
                    height: 30 * fem,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF90DCD0).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8 * fem),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      size: 20 * fem,
                      color: const Color(0xFF90DCD0),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    double fem,
    double thumbRadius,
    bool needsScroll,
    double itemWidth,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        /// LABELS
        Row(
          children: List.generate(
            widget.values.length,
            (index) => needsScroll
                ? SizedBox(
                    width: itemWidth,
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
                  )
                : Expanded(
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
                    height: (index % 3 == 0) ? 11 * fem : 7 * fem,
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

        /// TRACK + SLIDER
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

                    // Auto-scroll to keep selected range visible
                    if (needsScroll) {
                      _autoScrollToRange(start, end, fem, itemWidth);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Auto-scroll to keep the selected range visible
  void _autoScrollToRange(int start, int end, double fem, double itemWidth) {
    if (!mounted || !_scrollController.hasClients) return;

    final startOffset = start * itemWidth;
    final endOffset = end * itemWidth;
    final viewportWidth = _scrollController.position.viewportDimension;
    final currentOffset = _scrollController.offset;

    // Check if range is outside visible area
    if (startOffset < currentOffset) {
      // Scroll left to show start
      _scrollController.animateTo(
        (startOffset - itemWidth).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else if (endOffset > currentOffset + viewportWidth) {
      // Scroll right to show end
      _scrollController.animateTo(
        (endOffset - viewportWidth + itemWidth * 2).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
