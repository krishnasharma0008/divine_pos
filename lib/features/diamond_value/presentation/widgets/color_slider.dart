import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/scroll_side_button.dart';

class ColorSliderWidget extends StatefulWidget {
  final List<String> values;
  final int index;
  final ValueChanged<int> onChanged;

  const ColorSliderWidget({
    super.key,
    required this.values,
    required this.index,
    required this.onChanged,
  });

  @override
  State<ColorSliderWidget> createState() => _ColorSliderWidgetState();
}

class _ColorSliderWidgetState extends State<ColorSliderWidget> {
  late int _selectedIndex;
  final ScrollController _scrollController = ScrollController();

  bool _showArrows = false;
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  static const Color _tickActive = Color(0xFF1A9E8F);
  static const Color _tickInactive = Color(0xFFD9D9D9);
  static const Color _trackBorder = Color(0xFFBEE4DD);
  static const Color _thumbColor = Color(0xFFA9E7DF);

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index.clamp(
      0,
      widget.values.isEmpty ? 0 : widget.values.length - 1,
    );

    _scrollController.addListener(_updateScrollButtons);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfScrollNeeded();
      _updateScrollButtons();
    });
  }

  @override
  void didUpdateWidget(covariant ColorSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index || oldWidget.values != widget.values) {
      setState(() {
        _selectedIndex = widget.index.clamp(
          0,
          widget.values.isEmpty ? 0 : widget.values.length - 1,
        );
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkIfScrollNeeded();
        _updateScrollButtons();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollButtons);
    _scrollController.dispose();
    super.dispose();
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

  void _selectIndex(int index, double itemWidth) {
    if (index < 0 || index >= widget.values.length) return;
    setState(() => _selectedIndex = index);
    widget.onChanged(index);
    _autoScrollToIndex(index, itemWidth);
  }

  void _autoScrollToIndex(int index, double itemWidth) {
    if (!_scrollController.hasClients) return;
    final targetCenter = index * itemWidth + itemWidth / 2;
    final viewportW = _scrollController.position.viewportDimension;
    final newOffset = (targetCenter - viewportW / 2).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController
        .animateTo(
          newOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        )
        .then((_) => _updateScrollButtons());
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;
    final double itemWidth = 80 * fem;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * fem, vertical: 10 * fem),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.transparent, width: 1.5),
        borderRadius: BorderRadius.circular(16 * fem),
      ),
      child: SizedBox(
        height: 88 * fem,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final contentWidth = widget.values.length * itemWidth;
            final needsScroll = contentWidth > totalWidth;

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
                      width: needsScroll ? contentWidth : totalWidth,
                      child: _buildStrip(
                        fem: fem,
                        itemWidth: itemWidth,
                        contentWidth: contentWidth,
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
    );
  }

  Widget _buildStrip({
    required double fem,
    required double itemWidth,
    required double contentWidth,
  }) {
    final double thumbW = 10 * fem;
    final double thumbH = 15 * fem;
    final double thumbLeft =
        _selectedIndex * itemWidth + (itemWidth - thumbW) / 2;

    return SizedBox(
      width: contentWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(widget.values.length, (index) {
              final isSelected = index == _selectedIndex;
              return SizedBox(
                width: itemWidth,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _selectIndex(index, itemWidth),
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
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected ? _tickActive : _tickInactive,
                          ),
                        ),
                      ),
                      SizedBox(height: 10 * fem),
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          width: isSelected ? 4 * fem : 3 * fem,
                          height: isSelected
                              ? 14 * fem
                              : (index % 3 == 0 ? 11 * fem : 7 * fem),
                          decoration: BoxDecoration(
                            color: isSelected ? _tickActive : _tickInactive,
                            borderRadius: BorderRadius.circular(1.5 * fem),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 10 * fem),
          SizedBox(
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
                      border: Border.all(color: _trackBorder, width: 1),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(widget.values.length, (index) {
                    return SizedBox(
                      width: itemWidth,
                      height: thumbH,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _selectIndex(index, itemWidth),
                        child: const SizedBox.expand(),
                      ),
                    );
                  }),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  left: thumbLeft,
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
        ],
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
  bool shouldRepaint(_DiamondPainter old) => old.color != color;
}
