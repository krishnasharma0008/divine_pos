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

enum _DragThumb { start, end }

class _RangeSelectorState extends State<RangeSelector> {
  late int _startIndex;
  late int _endIndex;

  final ScrollController _scrollController = ScrollController();
  _DragThumb? _draggingThumb;
  double? _dragStartDx;

  static const Color _tickActive = Color(0xFFBEE4DD);
  static const Color _tickInactive = Color(0xFFD9D9D9);
  static const Color _activeTrackColor = Color(0xFFCFF4EE);
  static const Color _thumbColor = Color(0xFFA9E7DF);
  static const Color _trackBorderColor = Color(0xFFBEE4DD);

  @override
  void initState() {
    super.initState();
    _syncIndexes();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.values.isEmpty) return;
      _autoScrollToIndex((_startIndex + _endIndex) ~/ 2, _itemWidth);
    });
  }

  @override
  void didUpdateWidget(covariant RangeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialStartIndex != widget.initialStartIndex ||
        oldWidget.initialEndIndex != widget.initialEndIndex ||
        oldWidget.values != widget.values) {
      _syncIndexes();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || widget.values.isEmpty) return;
        _autoScrollToIndex((_startIndex + _endIndex) ~/ 2, _itemWidth);
      });
    }
  }

  double get _fem => ScaleSize.aspectRatio;
  double get _itemWidth => 80 * _fem;

  void _syncIndexes() {
    final maxIndex = widget.values.isEmpty ? 0 : widget.values.length - 1;

    _startIndex = widget.initialStartIndex.clamp(0, maxIndex);
    _endIndex = widget.initialEndIndex.clamp(0, maxIndex);

    if (_startIndex > _endIndex) {
      final temp = _startIndex;
      _startIndex = _endIndex;
      _endIndex = temp;
    }
  }

  String _displayText(String value) {
    return widget.valueToChipText?.call(value) ?? value;
  }

  void _emitRangeChanged() {
    if (widget.values.isEmpty) return;
    widget.onRangeChanged(widget.values[_startIndex], widget.values[_endIndex]);
  }

  double _centerX(int index, double itemWidth) {
    return index * itemWidth + itemWidth / 2;
  }

  int _indexFromLocalDx(double dx, double itemWidth) {
    if (widget.values.isEmpty) return 0;
    final raw = (dx / itemWidth).round();
    return raw.clamp(0, widget.values.length - 1);
  }

  void _handleDragStart(double localDx, double itemWidth) {
    _dragStartDx = localDx;

    if (_startIndex == _endIndex) {
      _draggingThumb = null;
      return;
    }

    final startCenter = _centerX(_startIndex, itemWidth);
    final endCenter = _centerX(_endIndex, itemWidth);

    final distanceToStart = (localDx - startCenter).abs();
    final distanceToEnd = (localDx - endCenter).abs();

    _draggingThumb = distanceToStart <= distanceToEnd
        ? _DragThumb.start
        : _DragThumb.end;
  }

  void _resolveThumbWhenOverlapped(double localDx) {
    if (_startIndex != _endIndex) return;
    if (_draggingThumb != null) return;
    if (_dragStartDx == null) return;

    final delta = localDx - _dragStartDx!;

    if (delta < 0) {
      _draggingThumb = _DragThumb.start;
    } else if (delta > 0) {
      _draggingThumb = _DragThumb.end;
    }
  }

  void _handleDragUpdate(double localDx, double itemWidth) {
    if (widget.values.isEmpty) return;

    _resolveThumbWhenOverlapped(localDx);
    if (_draggingThumb == null) return;

    final index = _indexFromLocalDx(localDx, itemWidth);

    if (_draggingThumb == _DragThumb.start) {
      final nextStart = index.clamp(0, _endIndex);
      if (nextStart == _startIndex) return;

      setState(() {
        _startIndex = nextStart;
      });
    } else {
      final nextEnd = index.clamp(_startIndex, widget.values.length - 1);
      if (nextEnd == _endIndex) return;

      setState(() {
        _endIndex = nextEnd;
      });
    }

    _emitRangeChanged();
  }

  void _handleDragEnd(double itemWidth) {
    if (_draggingThumb == _DragThumb.start) {
      _autoScrollToIndex(_startIndex, itemWidth);
    } else if (_draggingThumb == _DragThumb.end) {
      _autoScrollToIndex(_endIndex, itemWidth);
    } else if (_startIndex == _endIndex) {
      _autoScrollToIndex(_startIndex, itemWidth);
    }

    _draggingThumb = null;
    _dragStartDx = null;
  }

  void _autoScrollToIndex(int index, double itemWidth) {
    if (!_scrollController.hasClients) return;

    final targetCenter = _centerX(index, itemWidth);
    final viewportWidth = _scrollController.position.viewportDimension;

    final newOffset = (targetCenter - viewportWidth / 2).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fem = _fem;
    final itemWidth = _itemWidth;
    final arrowsWidth = 76 * fem;

    final String startValue = widget.values.isEmpty
        ? ''
        : widget.values[_startIndex];
    final String endValue = widget.values.isEmpty
        ? ''
        : widget.values[_endIndex];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * fem, vertical: 10 * fem),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.transparent, width: 1.5),
        borderRadius: BorderRadius.circular(16 * fem),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MyText(
                widget.label,
                style: TextStyle(
                  fontSize: 14 * fem,
                  fontFamily: 'Rushter Glory',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              _buildValueChip(_displayText(startValue), fem),
              SizedBox(width: 6 * fem),
              const Text('-'),
              SizedBox(width: 6 * fem),
              _buildValueChip(_displayText(endValue), fem),
            ],
          ),
          SizedBox(height: 18 * fem),
          if (widget.values.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final contentWidth = widget.values.length * itemWidth;
                final showArrows = contentWidth > totalWidth;
                final sliderWidth = showArrows
                    ? totalWidth - arrowsWidth
                    : totalWidth;

                return Row(
                  children: [
                    if (showArrows) ...[
                      _ArrowButton(
                        icon: Icons.chevron_left,
                        fem: fem,
                        onTap: _scrollLeft,
                      ),
                      SizedBox(width: 8 * fem),
                    ],
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: contentWidth > sliderWidth
                            ? const BouncingScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        child: SizedBox(
                          width: contentWidth,
                          child: _buildStrip(
                            fem: fem,
                            itemWidth: itemWidth,
                            contentWidth: contentWidth,
                          ),
                        ),
                      ),
                    ),
                    if (showArrows) ...[
                      SizedBox(width: 8 * fem),
                      _ArrowButton(
                        icon: Icons.chevron_right,
                        fem: fem,
                        onTap: _scrollRight,
                      ),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStrip({
    required double fem,
    required double itemWidth,
    required double contentWidth,
  }) {
    final double thumbW = 10 * fem;
    final double thumbH = 15 * fem;

    final double startCenter = _centerX(_startIndex, itemWidth);
    final double endCenter = _centerX(_endIndex, itemWidth);

    final double startLeft = startCenter - thumbW / 2;
    final double endLeft = endCenter - thumbW / 2;

    final double activeLeft = startCenter;
    final double activeRight = endCenter;
    final double activeWidth = (activeRight - activeLeft).abs();

    return SizedBox(
      width: contentWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(widget.values.length, (index) {
              final bool isInRange = index >= _startIndex && index <= _endIndex;
              final bool isEdge = index == _startIndex || index == _endIndex;

              return SizedBox(
                width: itemWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        widget.values[index],
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          fontSize: 11 * fem,
                          fontWeight: isEdge
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isInRange ? Colors.black : _tickInactive,
                        ),
                      ),
                    ),
                    SizedBox(height: 10 * fem),
                    Center(
                      child: Container(
                        width: isEdge ? 4 * fem : 3 * fem,
                        height: 11 * fem,
                        decoration: BoxDecoration(
                          color: isInRange ? _tickActive : _tickInactive,
                          borderRadius: BorderRadius.circular(1.5 * fem),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 10 * fem),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (details) {
              _handleDragStart(details.localPosition.dx, itemWidth);
            },
            onHorizontalDragUpdate: (details) {
              _handleDragUpdate(details.localPosition.dx, itemWidth);
            },
            onHorizontalDragEnd: (_) {
              _handleDragEnd(itemWidth);
            },
            child: SizedBox(
              height: thumbH,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 6 * fem,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3 * fem),
                        border: Border.all(color: _trackBorderColor, width: 1),
                      ),
                    ),
                  ),
                  Positioned(
                    left: activeLeft,
                    top: (thumbH - 6 * fem) / 2,
                    child: Container(
                      width: activeWidth == 0 ? thumbW : activeWidth,
                      height: 6 * fem,
                      decoration: BoxDecoration(
                        color: _activeTrackColor,
                        borderRadius: BorderRadius.circular(3 * fem),
                      ),
                    ),
                  ),
                  Positioned(
                    left: startLeft,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: SizedBox(
                        width: thumbW,
                        child: Center(
                          child: CustomPaint(
                            size: Size(thumbW, thumbH),
                            painter: _DiamondPainter(color: _thumbColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: endLeft,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: SizedBox(
                        width: thumbW,
                        child: Center(
                          child: CustomPaint(
                            size: Size(thumbW, thumbH),
                            painter: _DiamondPainter(color: _thumbColor),
                          ),
                        ),
                      ),
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

class _DiamondPainter extends CustomPainter {
  final Color color;

  const _DiamondPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final path = Path()
      ..moveTo(cx, 0)
      ..lineTo(size.width, cy)
      ..lineTo(cx, size.height)
      ..lineTo(0, cy)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_DiamondPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final double fem;
  final VoidCallback onTap;

  const _ArrowButton({
    required this.icon,
    required this.fem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8 * fem),
      child: Container(
        width: 30 * fem,
        height: 30 * fem,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF90DCD0).withOpacity(0.2),
          borderRadius: BorderRadius.circular(8 * fem),
        ),
        child: Icon(icon, size: 20 * fem, color: const Color(0xFF90DCD0)),
      ),
    );
  }
}
