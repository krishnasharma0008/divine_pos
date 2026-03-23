import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:flutter/material.dart';

class ColorSliderWidget extends StatelessWidget {
  final List<String> values;
  final int index;
  final ValueChanged<int> onChanged;

  const ColorSliderWidget({
    super.key,
    required this.values,
    required this.index,
    required this.onChanged,
  });

  static const Color _tickActive = Color(0xFF1A9E8F);
  static const Color _tickInactive = Color(0xFFD9D9D9);
  static const Color _trackBorder = Color(0xFFBEE4DD);
  static const Color _thumbColor = Color(0xFFA9E7DF);

  int get _currentIndex => index.clamp(0, values.length - 1);

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;
    final double itemWidth = 50 * fem;
    final double arrowsWidth = 76 * fem;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * fem, vertical: 10 * fem),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.transparent, width: 1.5),
        borderRadius: BorderRadius.circular(16 * fem),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final contentWidth = values.length * itemWidth;
          final showArrows = contentWidth > totalWidth;
          final sliderWidth = showArrows
              ? totalWidth - arrowsWidth
              : totalWidth;
          final needsScroll = contentWidth > sliderWidth;

          final scrollController = ScrollController();

          void scrollLeft() {
            if (!scrollController.hasClients) return;
            scrollController.animateTo(
              (scrollController.offset - 150).clamp(
                0.0,
                scrollController.position.maxScrollExtent,
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }

          void scrollRight() {
            if (!scrollController.hasClients) return;
            scrollController.animateTo(
              (scrollController.offset + 150).clamp(
                0.0,
                scrollController.position.maxScrollExtent,
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }

          void selectIndex(int i) {
            onChanged(i);
            if (!needsScroll || !scrollController.hasClients) return;
            final offset = i * itemWidth;
            final viewportW = scrollController.position.viewportDimension;
            final currentOff = scrollController.offset;

            if (offset < currentOff) {
              scrollController.animateTo(
                (offset - itemWidth).clamp(
                  0.0,
                  scrollController.position.maxScrollExtent,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            } else if (offset > currentOff + viewportW - itemWidth) {
              scrollController.animateTo(
                (offset - viewportW + itemWidth * 2).clamp(
                  0.0,
                  scrollController.position.maxScrollExtent,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          }

          return Row(
            children: [
              if (showArrows) ...[
                _ArrowButton(
                  icon: Icons.chevron_left,
                  fem: fem,
                  onTap: scrollLeft,
                ),
                SizedBox(width: 8 * fem),
              ],
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: needsScroll
                      ? null
                      : const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    width: needsScroll ? contentWidth : sliderWidth,
                    child: _buildItems(
                      fem: fem,
                      needsScroll: needsScroll,
                      itemWidth: itemWidth,
                      trackWidth: needsScroll ? contentWidth : sliderWidth,
                      onSelect: selectIndex,
                    ),
                  ),
                ),
              ),
              if (showArrows) ...[
                SizedBox(width: 8 * fem),
                _ArrowButton(
                  icon: Icons.chevron_right,
                  fem: fem,
                  onTap: scrollRight,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildItems({
    required double fem,
    required bool needsScroll,
    required double itemWidth,
    required double trackWidth,
    required ValueChanged<int> onSelect,
  }) {
    final double thumbW = 10 * fem;
    final double thumbH = 15 * fem;

    // Single cell width shared by labels, ticks and thumb.
    final int count = values.isEmpty ? 1 : values.length;
    final double cellWidth = needsScroll
        ? itemWidth
        : (trackWidth / count.toDouble());

    // Thumb left so that its center aligns under the label center.
    final double thumbLeft =
        _currentIndex * cellWidth + (cellWidth - thumbW) / 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // LABELS (tappable)
        Row(
          children: List.generate(values.length, (i) {
            final isSelected = i == _currentIndex;
            final label = GestureDetector(
              onTap: () => onSelect(i),
              behavior: HitTestBehavior.opaque,
              child: Text(
                values[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11 * fem,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? _tickActive : _tickInactive,
                ),
              ),
            );
            return needsScroll
                ? SizedBox(width: cellWidth, child: label)
                : Expanded(child: label);
          }),
        ),

        SizedBox(height: 10 * fem),

        // TICKS (tappable)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: thumbW / 2),
          child: Row(
            children: List.generate(values.length, (i) {
              final isSelected = i == _currentIndex;
              final tick = GestureDetector(
                onTap: () => onSelect(i),
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    width: isSelected ? 4 * fem : 3 * fem,
                    height: isSelected
                        ? 14 * fem
                        : (i % 3 == 0 ? 11 * fem : 7 * fem),
                    decoration: BoxDecoration(
                      color: isSelected ? _tickActive : _tickInactive,
                      borderRadius: BorderRadius.circular(1.5 * fem),
                    ),
                  ),
                ),
              );
              return needsScroll
                  ? SizedBox(width: cellWidth, child: tick)
                  : Expanded(child: tick);
            }),
          ),
        ),

        SizedBox(height: 10 * fem),

        // TRACK + DIAMOND THUMB (thumb exactly under label)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: thumbW / 2),
          child: SizedBox(
            height: thumbH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Track bar
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

                // Tap hit areas over each position
                Row(
                  children: List.generate(values.length, (i) {
                    final hit = GestureDetector(
                      onTap: () => onSelect(i),
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox.expand(),
                    );
                    return needsScroll
                        ? SizedBox(width: cellWidth, height: thumbH, child: hit)
                        : Expanded(child: hit);
                  }),
                ),

                // Diamond thumb aligned under the selected label
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
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Diamond thumb painter
// ---------------------------------------------------------------------------
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

// ---------------------------------------------------------------------------
// Reusable arrow button
// ---------------------------------------------------------------------------
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
