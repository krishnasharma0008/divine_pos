import 'package:flutter/material.dart';
import '../../../../shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import '../../../../shared/widgets/scroll_side_button.dart';

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
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

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

    _scrollController.addListener(_updateScrollButtons);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfScrollNeeded();
      _updateScrollButtons();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollButtons);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CaratRangeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.values != widget.values ||
        oldWidget.initialStartIndex != widget.initialStartIndex ||
        oldWidget.initialEndIndex != widget.initialEndIndex) {
      setState(() {
        _range = RangeValues(
          widget.initialStartIndex
              .clamp(0, widget.values.length - 1)
              .toDouble(),
          widget.initialEndIndex.clamp(0, widget.values.length - 1).toDouble(),
        );
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkIfScrollNeeded();
        _updateScrollButtons();
      });
    }
  }

  void _checkIfScrollNeeded() {
    if (!mounted || !_scrollController.hasClients) return;

    final hasOverflow = _scrollController.position.maxScrollExtent > 0;

    if (hasOverflow != _showArrows) {
      setState(() {
        _showArrows = hasOverflow;
      });
    }
  }

  void _updateScrollButtons() {
    if (!_scrollController.hasClients) {
      if (_showArrows || _canScrollLeft || _canScrollRight) {
        setState(() {
          _showArrows = false;
          _canScrollLeft = false;
          _canScrollRight = false;
        });
      }
      return;
    }

    final position = _scrollController.position;
    final hasOverflow = position.maxScrollExtent > 0;
    final canLeft = position.pixels > 0;
    final canRight = position.pixels < position.maxScrollExtent;

    if (hasOverflow != _showArrows ||
        canLeft != _canScrollLeft ||
        canRight != _canScrollRight) {
      setState(() {
        _showArrows = hasOverflow;
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  void _scrollLeft() {
    if (!_scrollController.hasClients) return;
    _scrollController
        .animateTo(
          (_scrollController.offset - 150).clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        )
        .then((_) => _updateScrollButtons());
  }

  void _scrollRight() {
    if (!_scrollController.hasClients) return;
    _scrollController
        .animateTo(
          (_scrollController.offset + 150).clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        )
        .then((_) => _updateScrollButtons());
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;
    final String startValue = widget.values[_startIndex];
    final String endValue = widget.values[_endIndex];
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
              _buildValueChip(chipFormatter(startValue), fem),
              SizedBox(width: 6 * fem),
              const Text('-'),
              SizedBox(width: 6 * fem),
              _buildValueChip(chipFormatter(endValue), fem),
            ],
          ),
          SizedBox(height: 18 * fem),
          SizedBox(
            height: 88 * fem,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final itemWidth = 50 * fem;
                final calculatedWidth = widget.values.length * itemWidth;
                final needsScroll = calculatedWidth > availableWidth;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _checkIfScrollNeeded();
                    _updateScrollButtons();
                  }
                });

                return Stack(
                  children: [
                    Positioned.fill(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: needsScroll
                            ? const BouncingScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          left: _showArrows ? 34 * fem : 12 * fem,
                          right: _showArrows ? 34 * fem : 12 * fem,
                        ),
                        child: SizedBox(
                          width: needsScroll ? calculatedWidth : availableWidth,
                          child: _buildContent(
                            fem,
                            thumbRadius,
                            needsScroll,
                            itemWidth,
                          ),
                        ),
                      ),
                    ),
                    if (_showArrows && _canScrollLeft)
                      ScrollSideButton(
                        isRight: false,
                        onTap: _scrollLeft,
                        fem: fem,
                      ),
                    if (_showArrows && _canScrollRight)
                      ScrollSideButton(
                        isRight: true,
                        onTap: _scrollRight,
                        fem: fem,
                      ),
                  ],
                );
              },
            ),
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: thumbRadius),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 6 * fem,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3 * fem),
                  border: Border.all(color: tickColor, width: 1),
                ),
              ),
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

                    if (needsScroll) {
                      _autoScrollToRange(start, end, itemWidth);
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

  void _autoScrollToRange(int start, int end, double itemWidth) {
    if (!mounted || !_scrollController.hasClients) return;

    final startOffset = start * itemWidth;
    final endOffset = end * itemWidth;
    final viewportWidth = _scrollController.position.viewportDimension;
    final currentOffset = _scrollController.offset;

    if (startOffset < currentOffset) {
      _scrollController
          .animateTo(
            (startOffset - itemWidth).clamp(
              0.0,
              _scrollController.position.maxScrollExtent,
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          )
          .then((_) => _updateScrollButtons());
    } else if (endOffset > currentOffset + viewportWidth) {
      _scrollController
          .animateTo(
            (endOffset - viewportWidth + itemWidth * 2).clamp(
              0.0,
              _scrollController.position.maxScrollExtent,
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          )
          .then((_) => _updateScrollButtons());
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
