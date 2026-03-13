import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// ScaleSize stub — replace with your real shared/utils/scale_size.dart
// ---------------------------------------------------------------------------
class ScaleSize {
  static double aspectRatio = 1.0;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    aspectRatio = (size.width / 1024).clamp(0.6, 1.6);
  }
}

// ---------------------------------------------------------------------------
// MyText stub — replace with your real shared/widgets/text.dart
// ---------------------------------------------------------------------------
class MyText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const MyText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}

// ---------------------------------------------------------------------------
// CaratSelector — single slider (was CaratRangeSelector)
// ---------------------------------------------------------------------------
class CaratSelector extends StatefulWidget {
  final String label;
  final List<String> values;
  final int initialIndex;
  final void Function(String value) onChanged;
  final String Function(String value)? valueToChipText;

  const CaratSelector({
    super.key,
    required this.label,
    required this.values,
    required this.initialIndex,
    required this.onChanged,
    this.valueToChipText,
  });

  @override
  State<CaratSelector> createState() => _CaratSelectorState();
}

class _CaratSelectorState extends State<CaratSelector> {
  late double _index;
  final ScrollController _scrollController = ScrollController();
  bool _showArrows = false;

  final Color tickColor = const Color(0xFFBEE4DD);
  final Color activeTrackColor = const Color(0xFFCFF4EE);

  int get _currentIndex => _index.round();

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.values.length - 1).toDouble();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkIfScrollNeeded());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CaratSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      setState(() {
        _index = widget.initialIndex
            .clamp(0, widget.values.length - 1)
            .toDouble();
      });
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _checkIfScrollNeeded(),
      );
    }
  }

  void _checkIfScrollNeeded() {
    if (!mounted || !_scrollController.hasClients) return;
    final hasOverflow = _scrollController.position.maxScrollExtent > 0;
    if (hasOverflow != _showArrows) {
      setState(() => _showArrows = hasOverflow);
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
    ScaleSize.init(context);
    final fem = ScaleSize.aspectRatio;

    final String currentValue = widget.values[_currentIndex];
    final chipFormatter = widget.valueToChipText ?? (String v) => v;
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
          // HEADER — label + single value chip
          Row(
            children: [
              MyText(
                widget.label,
                style: TextStyle(fontSize: 14 * fem, fontFamily: 'Georgia'),
              ),
              const Spacer(),
              //_buildValueChip(chipFormatter(currentValue), fem),
            ],
          ),

          SizedBox(height: 18 * fem),

          // SCROLLABLE SECTION WITH ARROWS
          Row(
            children: [
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

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    final itemWidth = 50 * fem;
                    final calculatedWidth = widget.values.length * itemWidth;
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
        // LABELS — active label is black, others grey
        Row(
          children: List.generate(widget.values.length, (index) {
            final isActive = index <= _currentIndex;
            final label = Text(
              widget.values[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11 * fem,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.black : const Color(0xFFD9D9D9),
              ),
            );
            return needsScroll
                ? SizedBox(width: itemWidth, child: label)
                : Expanded(child: label);
          }),
        ),

        SizedBox(height: 10 * fem),

        // TICKS — filled up to current index
        Padding(
          padding: EdgeInsets.symmetric(horizontal: thumbRadius),
          child: Row(
            children: List.generate(widget.values.length, (index) {
              return Expanded(
                child: Center(
                  child: Container(
                    width: 3 * fem,
                    height: (index % 3 == 0) ? 11 * fem : 7 * fem,
                    decoration: BoxDecoration(
                      color: index <= _currentIndex
                          ? tickColor
                          : const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(1.5 * fem),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        SizedBox(height: 10 * fem),

        // TRACK + SINGLE SLIDER
        Padding(
          padding: EdgeInsets.symmetric(horizontal: thumbRadius),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Base bar
              Container(
                height: 6 * fem,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3 * fem),
                  border: Border.all(color: tickColor, width: 1),
                ),
              ),

              // Single Slider
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4 * fem,
                  inactiveTrackColor: Colors.transparent,
                  activeTrackColor: activeTrackColor,
                  thumbColor: const Color(0xFFA9E7DF),
                  overlayColor: const Color(0xFFBFE8E3).withOpacity(0.25),
                  thumbShape: DiamondThumbShape(
                    width: 10 * fem,
                    height: 15 * fem,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: 16 * fem,
                  ),
                  trackShape: const RoundedRectSliderTrackShape(),
                ),
                child: Slider(
                  min: 0,
                  max: (widget.values.length - 1).toDouble(),
                  divisions: widget.values.length - 1,
                  value: _index,
                  onChanged: (v) {
                    final i = v.round();
                    setState(() => _index = i.toDouble());
                    widget.onChanged(widget.values[i]);
                    if (needsScroll) _autoScrollToIndex(i, itemWidth);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _autoScrollToIndex(int index, double itemWidth) {
    if (!mounted || !_scrollController.hasClients) return;
    final offset = index * itemWidth;
    final viewportW = _scrollController.position.viewportDimension;
    final currentOff = _scrollController.offset;

    if (offset < currentOff) {
      _scrollController.animateTo(
        (offset - itemWidth).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else if (offset > currentOff + viewportW - itemWidth) {
      _scrollController.animateTo(
        (offset - viewportW + itemWidth * 2).clamp(
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

// ---------------------------------------------------------------------------
// DiamondThumbShape — single-slider version of your diamond thumb
// ---------------------------------------------------------------------------
class DiamondThumbShape extends SliderComponentShape {
  final double width;
  final double height;

  const DiamondThumbShape({this.width = 10, this.height = 15});

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
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
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
