import 'package:flutter/material.dart';
import '../../data/diamond_config.dart';

class ShapeSelector extends StatelessWidget {
  final DiamondShape selected;
  final ValueChanged<DiamondShape> onChanged;

  const ShapeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: DiamondShape.values.map((shape) {
        final isSelected = shape == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 14),
          child: GestureDetector(
            onTap: () => onChanged(shape),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFD4ECE6)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF5AB5A8)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(32, 32),
                      painter: _ShapeIconPainter(shape: shape),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _shapeName(shape),
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected
                        ? const Color(0xFF3AA09A)
                        : const Color(0xFF6B6B6B),
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _shapeName(DiamondShape s) {
    switch (s) {
      case DiamondShape.round:
        return 'Round';
      case DiamondShape.princess:
        return 'Princess';
      case DiamondShape.pear:
        return 'Pear';
      case DiamondShape.oval:
        return 'Oval';
    }
  }
}

class _ShapeIconPainter extends CustomPainter {
  final DiamondShape shape;
  _ShapeIconPainter({required this.shape});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = const Color(0xFFDDDDEE)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFFAAAAAA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (shape) {
      case DiamondShape.round:
        canvas.drawCircle(Offset(cx, cy), 13, bgPaint);
        canvas.drawCircle(Offset(cx, cy), 13, strokePaint);
        canvas.drawCircle(Offset(cx, cy), 9, fillPaint);
        break;
      case DiamondShape.princess:
        canvas.drawRect(
          Rect.fromCenter(center: Offset(cx, cy), width: 22, height: 22),
          bgPaint,
        );
        canvas.drawRect(
          Rect.fromCenter(center: Offset(cx, cy), width: 22, height: 22),
          strokePaint,
        );
        canvas.drawRect(
          Rect.fromCenter(center: Offset(cx, cy), width: 15, height: 15),
          fillPaint,
        );
        break;
      case DiamondShape.pear:
        final path = Path();
        path.moveTo(cx, cy - 14);
        path.cubicTo(cx + 12, cy - 14, cx + 13, cy, cx + 10, cy + 6);
        path.quadraticBezierTo(cx, cy + 14, cx - 10, cy + 6);
        path.cubicTo(cx - 13, cy, cx - 12, cy - 14, cx, cy - 14);
        canvas.drawPath(path, bgPaint);
        canvas.drawPath(path, strokePaint);
        canvas.drawPath(
          path,
          fillPaint..color = fillPaint.color.withOpacity(0.5),
        );
        break;
      case DiamondShape.oval:
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy), width: 20, height: 28),
          bgPaint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy), width: 20, height: 28),
          strokePaint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy), width: 14, height: 20),
          fillPaint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(_ShapeIconPainter old) => old.shape != shape;
}
