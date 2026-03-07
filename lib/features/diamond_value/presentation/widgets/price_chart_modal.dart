import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../data/diamond_config.dart';

class PriceChartModal extends StatelessWidget {
  final DiamondConfig config;
  const PriceChartModal({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        width: 560,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '22nd September 2025',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B6B6B)),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFDDDDDD)),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Color(0xFF6B6B6B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Metrics row
            Row(
              children: [
                _MetricChip(
                  label: 'Price',
                  value: '₹1,25,000',
                  isNegative: false,
                ),
                const SizedBox(width: 20),
                _MetricChip(label: 'Growth', value: '-18%', isNegative: true),
              ],
            ),
            const SizedBox(height: 20),

            // Chart
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8FC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(painter: _ChartPainter(), child: Container()),
            ),
            const SizedBox(height: 6),

            // X axis labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                    const [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec',
                        ]
                        .map(
                          (m) => Text(
                            m,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isNegative;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.isNegative,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B6B6B)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 1,
          height: 14,
          color: const Color(0xFFDDDDDD),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isNegative
                ? const Color(0xFFE05050)
                : const Color(0xFF3A6FDF),
          ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 0.8;
    for (int i = 1; i < 6; i++) {
      final y = h * i / 6;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Y-axis labels
    final labelStyle = const TextStyle(fontSize: 9, color: Color(0xFFAAAAAA));
    final labels = [
      '₹15,000',
      '₹12,500',
      '₹10,000',
      '₹7,500',
      '₹5,000',
      '₹2,500',
    ];
    for (int i = 0; i < labels.length; i++) {
      final y = h * (i + 0.5) / 6;
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(4, y - tp.height / 2));
    }

    // Wave data points (normalized 0..1, y inverted)
    final pts = [
      0.45,
      0.42,
      0.48,
      0.44,
      0.40,
      0.43,
      0.38,
      0.42,
      0.40,
      0.37,
      0.35,
      0.32,
    ];
    final leftPad = 52.0;
    final rightPad = 16.0;
    final topPad = 16.0;
    final botPad = 20.0;
    final chartW = w - leftPad - rightPad;
    final chartH = h - topPad - botPad;

    List<Offset> offsets = [];
    for (int i = 0; i < pts.length; i++) {
      final x = leftPad + (i / (pts.length - 1)) * chartW;
      final y = topPad + pts[i] * chartH;
      offsets.add(Offset(x, y));
    }

    // Filled area gradient
    final gradPath = Path();
    gradPath.moveTo(offsets[0].dx, offsets[0].dy);
    for (int i = 1; i < offsets.length; i++) {
      final prev = offsets[i - 1];
      final curr = offsets[i];
      final cpx = (prev.dx + curr.dx) / 2;
      gradPath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }
    gradPath.lineTo(offsets.last.dx, h - botPad);
    gradPath.lineTo(offsets.first.dx, h - botPad);
    gradPath.close();

    final gradPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFC5C8F0).withOpacity(0.55),
          const Color(0xFFC5C8F0).withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(gradPath, gradPaint);

    // Line
    final linePath = Path();
    linePath.moveTo(offsets[0].dx, offsets[0].dy);
    for (int i = 1; i < offsets.length; i++) {
      final prev = offsets[i - 1];
      final curr = offsets[i];
      final cpx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xFF9898D0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Tooltip dots
    final dot1 = offsets[8]; // Sep
    final dot2 = offsets[10]; // Nov
    _drawTooltip(canvas, dot1, '₹1,25,000', above: true);
    _drawTooltip(canvas, dot2, '₹1,02,150', above: true);

    // Dot circles
    _drawDot(canvas, dot1);
    _drawDot(canvas, dot2);
  }

  void _drawDot(Canvas canvas, Offset pos) {
    canvas.drawCircle(pos, 5.5, Paint()..color = Colors.white);
    canvas.drawCircle(
      pos,
      5.5,
      Paint()
        ..color = const Color(0xFF3A6FDF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawTooltip(
    Canvas canvas,
    Offset pos,
    String text, {
    required bool above,
  }) {
    const rr = 4.0;
    const padding = EdgeInsets.symmetric(horizontal: 10, vertical: 5);
    const tipH = 22.0;

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Color(0xFF3A6FDF),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final tipW = tp.width + padding.horizontal;
    final offsetY = above ? -(tipH + 10) : 10.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pos.dx - tipW / 2, pos.dy + offsetY, tipW, tipH),
      const Radius.circular(rr),
    );

    canvas.drawRRect(rect, Paint()..color = Colors.white);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = const Color(0xFFE4E4E4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    tp.paint(
      canvas,
      Offset(pos.dx - tp.width / 2, pos.dy + offsetY + (tipH - tp.height) / 2),
    );
  }

  @override
  bool shouldRepaint(_ChartPainter old) => false;
}
