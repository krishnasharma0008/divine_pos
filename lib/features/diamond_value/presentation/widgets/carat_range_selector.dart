import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:divine_pos/shared/widgets/text.dart' show MyText;
import 'package:flutter/material.dart';

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
  late int _selectedIndex;
  final ScrollController _scrollController = ScrollController();
  bool _showArrows = false;

  static const Color _tickActive = Color(0xFF1A9E8F);
  static const Color _tickInactive = Color(0xFFD9D9D9);
  static const Color _trackBorder = Color(0xFFBEE4DD);
  static const Color _thumbColor = Color(0xFFA9E7DF);

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, widget.values.length - 1);
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
        _selectedIndex = widget.initialIndex.clamp(0, widget.values.length - 1);
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

  void _selectIndex(int index, double itemWidth) {
    setState(() => _selectedIndex = index);
    widget.onChanged(widget.values[index]);
    _autoScrollToIndex(index, itemWidth);
  }

  void _autoScrollToIndex(int index, double itemWidth) {
    if (!mounted || !_scrollController.hasClients) return;
    final targetCenter = index * itemWidth + itemWidth / 2;
    final viewportW = _scrollController.position.viewportDimension;
    final newOffset = (targetCenter - viewportW / 2).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;
    final double itemWidth = 50 * fem;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final contentWidth = widget.values.length * itemWidth;
        final showArrows = contentWidth > totalWidth;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8 * fem,
            vertical: 10 * fem,
          ),
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
                      child: _buildStrip(
                        fem: fem,
                        itemWidth: itemWidth,
                        contentWidth: contentWidth,
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
              ),
            ],
          ),
        );
      },
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
          // LABELS
          Row(
            children: List.generate(widget.values.length, (index) {
              final isSelected = index == _selectedIndex;
              return SizedBox(
                width: itemWidth,
                child: GestureDetector(
                  onTap: () => _selectIndex(index, itemWidth),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      widget.values[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11 * fem,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected ? _tickActive : _tickInactive,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          SizedBox(height: 10 * fem),

          // TICKS
          Row(
            children: List.generate(widget.values.length, (index) {
              final isSelected = index == _selectedIndex;
              return SizedBox(
                width: itemWidth,
                child: GestureDetector(
                  onTap: () => _selectIndex(index, itemWidth),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
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
                ),
              );
            }),
          ),

          SizedBox(height: 10 * fem),

          // TRACK + DIAMOND THUMB
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

                // Hit areas
                Row(
                  children: List.generate(widget.values.length, (index) {
                    return SizedBox(
                      width: itemWidth,
                      height: thumbH,
                      child: GestureDetector(
                        onTap: () => _selectIndex(index, itemWidth),
                        behavior: HitTestBehavior.opaque,
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
