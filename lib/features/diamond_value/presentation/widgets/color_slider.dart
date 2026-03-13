import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'carat_range_selector.dart'; // ScaleSize, MyText, DiamondThumbShape

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
  final ScrollController _scrollController = ScrollController();
  bool _showArrows = false;

  final Color tickColor = const Color(0xFFBEE4DD);
  final Color activeTrackColor = const Color(0xFFCFF4EE);

  // No internal _index — parent owns the index entirely
  int get _currentIndex => widget.index.clamp(0, widget.values.length - 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkIfScrollNeeded());
  }

  @override
  void didUpdateWidget(covariant ColorSliderWidget old) {
    super.didUpdateWidget(old);
    // Use listEquals so a new list instance with identical content doesn't trigger scroll recheck
    if (!listEquals(old.values, widget.values)) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _checkIfScrollNeeded(),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkIfScrollNeeded() {
    if (!mounted || !_scrollController.hasClients) return;
    final hasOverflow = _scrollController.position.maxScrollExtent > 0;
    if (hasOverflow != _showArrows) setState(() => _showArrows = hasOverflow);
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
    final double thumbRadius = (10 * fem) / 2;
    final currentValue = widget.values[_currentIndex];

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
              if (_showArrows) ...[
                _arrowBtn(Icons.chevron_left, _scrollLeft, fem),
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
                _arrowBtn(Icons.chevron_right, _scrollRight, fem),
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
        Row(
          children: List.generate(widget.values.length, (i) {
            final label = Text(
              widget.values[i],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11 * fem,
                fontWeight: FontWeight.w500,
                color: i <= _currentIndex
                    ? Colors.black
                    : const Color(0xFFD9D9D9),
              ),
            );
            return needsScroll
                ? SizedBox(width: itemWidth, child: label)
                : Expanded(child: label);
          }),
        ),
        SizedBox(height: 10 * fem),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: thumbRadius),
          child: Row(
            children: List.generate(
              widget.values.length,
              (i) => Expanded(
                child: Center(
                  child: Container(
                    width: 3 * fem,
                    height: (i % 3 == 0) ? 11 * fem : 7 * fem,
                    decoration: BoxDecoration(
                      color: i <= _currentIndex
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
                  value: _currentIndex.toDouble(),
                  onChanged: (v) {
                    final i = v.round();
                    widget.onChanged(i);
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

  Widget _arrowBtn(IconData icon, VoidCallback onTap, double fem) {
    return InkWell(
      onTap: onTap,
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
