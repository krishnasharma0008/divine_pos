import 'package:flutter/material.dart';
import '../../data/diamond_config.dart';
import 'dart:math' as math;

class DiamondRingPainter extends CustomPainter {
  final DiamondConfig config;
  DiamondRingPainter({required this.config});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Ring band
    final bandPaint = Paint()
      ..color = const Color(0xFFC8A96E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // Band ellipse bottom
    final bandRect = Rect.fromCenter(
      center: Offset(cx, cy + 28),
      width: 110,
      height: 14,
    );
    canvas.drawArc(bandRect, 0, math.pi, false, bandPaint);

    // Band top curve
    final path = Path();
    path.moveTo(cx - 55, cy + 28);
    path.quadraticBezierTo(cx, cy + 15, cx + 55, cy + 28);
    canvas.drawPath(path, bandPaint);

    // Diamond stone based on shape
    _drawDiamond(canvas, size, cx, cy - 10);
  }

  void _drawDiamond(Canvas canvas, Size size, double cx, double cy) {
    final isYellow = config.colorIndex >= 8;
    final Color stoneColor = isYellow ? const Color(0xFFE8C840) : Colors.white;
    final Color facetLight = isYellow
        ? const Color(0xFFF0D870)
        : const Color(0xFFE8E8F8);
    final Color facetMid = isYellow
        ? const Color(0xFFD4B030)
        : const Color(0xFFD8D8EE);
    final Color facetDark = isYellow
        ? const Color(0xFFC09820)
        : const Color(0xFFC8C8E0);

    switch (config.shape) {
      case DiamondShape.round:
        _drawRoundDiamond(
          canvas,
          cx,
          cy,
          stoneColor,
          facetLight,
          facetMid,
          facetDark,
        );
        break;
      case DiamondShape.princess:
        _drawPrincessDiamond(
          canvas,
          cx,
          cy,
          stoneColor,
          facetLight,
          facetMid,
          facetDark,
        );
        break;
      case DiamondShape.pear:
        _drawPearDiamond(
          canvas,
          cx,
          cy,
          stoneColor,
          facetLight,
          facetMid,
          facetDark,
        );
        break;
      case DiamondShape.oval:
        _drawOvalDiamond(
          canvas,
          cx,
          cy,
          stoneColor,
          facetLight,
          facetMid,
          facetDark,
        );
        break;
    }
  }

  void _drawRoundDiamond(
    Canvas canvas,
    double cx,
    double cy,
    Color base,
    Color light,
    Color mid,
    Color dark,
  ) {
    // Outer girdle
    final girdle = Paint()
      ..color = base.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 54, height: 10),
      girdle,
    );

    // Table (top)
    final tablePaint = Paint()..color = base;
    final tableRect = Rect.fromCenter(
      center: Offset(cx, cy - 4),
      width: 34,
      height: 16,
    );
    canvas.drawOval(tableRect, tablePaint);

    // Crown facets
    _drawPolygon(canvas, [
      Offset(cx, cy - 24),
      Offset(cx + 20, cy - 6),
      Offset(cx + 10, cy + 4),
      Offset(cx, cy + 8),
      Offset(cx - 10, cy + 4),
      Offset(cx - 20, cy - 6),
    ], light);

    // Pavilion
    _drawPolygon(canvas, [
      Offset(cx + 20, cy - 6),
      Offset(cx - 20, cy - 6),
      Offset(cx, cy + 20),
    ], mid);

    _drawPolygon(canvas, [
      Offset(cx, cy + 8),
      Offset(cx + 20, cy - 6),
      Offset(cx, cy + 20),
    ], light.withOpacity(0.6));

    // Outline
    final outline = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    _strokePolygon(canvas, [
      Offset(cx, cy - 24),
      Offset(cx + 20, cy - 6),
      Offset(cx, cy + 20),
      Offset(cx - 20, cy - 6),
    ], outline);
  }

  void _drawPrincessDiamond(
    Canvas canvas,
    double cx,
    double cy,
    Color base,
    Color light,
    Color mid,
    Color dark,
  ) {
    _drawPolygon(canvas, [
      Offset(cx - 18, cy - 18),
      Offset(cx + 18, cy - 18),
      Offset(cx + 18, cy + 8),
      Offset(cx - 18, cy + 8),
    ], base);
    _drawPolygon(canvas, [
      Offset(cx - 18, cy - 18),
      Offset(cx + 18, cy - 18),
      Offset(cx, cy - 2),
    ], light);
    _drawPolygon(canvas, [
      Offset(cx + 18, cy - 18),
      Offset(cx + 18, cy + 8),
      Offset(cx, cy - 2),
    ], mid);
    _drawPolygon(canvas, [
      Offset(cx - 18, cy + 8),
      Offset(cx + 18, cy + 8),
      Offset(cx, cy - 2),
    ], dark);
    _drawPolygon(canvas, [
      Offset(cx - 18, cy - 18),
      Offset(cx - 18, cy + 8),
      Offset(cx, cy - 2),
    ], light.withOpacity(0.7));
    final outline = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    _strokePolygon(canvas, [
      Offset(cx - 18, cy - 18),
      Offset(cx + 18, cy - 18),
      Offset(cx + 18, cy + 8),
      Offset(cx - 18, cy + 8),
    ], outline);
  }

  void _drawPearDiamond(
    Canvas canvas,
    double cx,
    double cy,
    Color base,
    Color light,
    Color mid,
    Color dark,
  ) {
    final path = Path();
    path.moveTo(cx, cy - 24);
    path.cubicTo(cx + 20, cy - 24, cx + 22, cy - 6, cx + 18, cy + 4);
    path.quadraticBezierTo(cx, cy + 22, cx - 18, cy + 4);
    path.cubicTo(cx - 22, cy - 6, cx - 20, cy - 24, cx, cy - 24);
    canvas.drawPath(path, Paint()..color = base);

    final pathLight = Path();
    pathLight.moveTo(cx, cy - 24);
    pathLight.cubicTo(cx + 20, cy - 24, cx + 22, cy - 6, cx + 18, cy + 4);
    pathLight.lineTo(cx, cy - 4);
    pathLight.close();
    canvas.drawPath(pathLight, Paint()..color = light.withOpacity(0.7));

    final pathDark = Path();
    pathDark.moveTo(cx, cy - 4);
    pathDark.quadraticBezierTo(cx, cy + 22, cx - 18, cy + 4);
    pathDark.lineTo(cx, cy - 4);
    pathDark.close();
    canvas.drawPath(pathDark, Paint()..color = dark.withOpacity(0.7));

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  void _drawOvalDiamond(
    Canvas canvas,
    double cx,
    double cy,
    Color base,
    Color light,
    Color mid,
    Color dark,
  ) {
    final ovalRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: 40,
      height: 54,
    );
    canvas.drawOval(ovalRect, Paint()..color = base);
    final leftHalf = Path()
      ..addArc(ovalRect, math.pi / 2, math.pi)
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(leftHalf, Paint()..color = light.withOpacity(0.5));
    canvas.drawOval(
      ovalRect,
      Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  void _drawPolygon(Canvas canvas, List<Offset> pts, Color color) {
    if (pts.isEmpty) return;
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (var i = 1; i < pts.length; i++) path.lineTo(pts[i].dx, pts[i].dy);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _strokePolygon(Canvas canvas, List<Offset> pts, Paint paint) {
    if (pts.isEmpty) return;
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (var i = 1; i < pts.length; i++) path.lineTo(pts[i].dx, pts[i].dy);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(DiamondRingPainter old) => old.config != config;
}
