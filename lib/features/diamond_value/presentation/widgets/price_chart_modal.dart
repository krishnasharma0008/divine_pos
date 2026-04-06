import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/diamond_config.dart';
import '../../provider/diamond_price_provider.dart';
import '../../../../shared/utils/scale_size.dart';

// ---------------------------------------------------------------------------
// Data model for a single compared month
// ---------------------------------------------------------------------------
class _MonthPrice {
  final DateTime month;
  final DateTime checkDate;
  final double price;
  final double difference;
  final String currencyLocale;
  final String currencyCode;

  _MonthPrice(
    this.month,
    this.checkDate,
    this.price,
    this.difference, {
    this.currencyLocale = 'en-IN',
    this.currencyCode = 'INR',
  });

  String get label => DateFormat('d MMM yy').format(month);
}

// ---------------------------------------------------------------------------
// Modal
// ---------------------------------------------------------------------------
class PriceChartModal extends ConsumerStatefulWidget {
  final DiamondConfig config;
  final double? currentPrice;

  const PriceChartModal({super.key, required this.config, this.currentPrice});

  @override
  ConsumerState<PriceChartModal> createState() => _PriceChartModalState();
}

class _PriceChartModalState extends ConsumerState<PriceChartModal> {
  final List<_MonthPrice> _entries = [];
  bool _loadingMonth = false;
  String? _error;

  // ── Dropdown selections ──────────────────────────────────────────────────
  int? _selYear;
  int? _selMonth;
  int? _selDay;

  double get fem => ScaleSize.aspectRatio;

  // ── Dropdown data helpers ────────────────────────────────────────────────

  final DateTime _now = DateTime.now();

  List<int> get _years =>
      List.generate(_now.year - 2012 + 1, (i) => 2012 + i).reversed.toList();

  List<int> get _months {
    if (_selYear == null) return [];
    final maxMonth = _selYear == _now.year ? _now.month : 12;
    return List.generate(maxMonth, (i) => i + 1);
  }

  List<int> get _days {
    if (_selYear == null || _selMonth == null) return [];
    final daysInMonth = DateUtils.getDaysInMonth(_selYear!, _selMonth!);
    final maxDay = (_selYear == _now.year && _selMonth == _now.month)
        ? _now.day
        : daysInMonth;
    return List.generate(maxDay, (i) => i + 1);
  }

  // ── Fetch ────────────────────────────────────────────────────────────────

  Future<void> _fetchPrice() async {
    if (_selYear == null || _selMonth == null || _selDay == null) return;

    final selectedDate = DateTime(_selYear!, _selMonth!, _selDay!);

    if (_entries.any(
      (e) =>
          e.month.year == selectedDate.year &&
          e.month.month == selectedDate.month &&
          e.month.day == selectedDate.day,
    )) {
      setState(
        () => _error =
            '${DateFormat('d MMMM yyyy').format(selectedDate)} is already added. Please select a different date.',
      );
      return;
    }

    setState(() {
      _loadingMonth = true;
      _error = null;
    });

    try {
      final result = await ref
          .read(diamondPriceRepositoryProvider)
          .comparePastPrices(
            shape: widget.config.shapeCode,
            colour: widget.config.colorLabel,
            clarity: widget.config.clarityLabel,
            cts: widget.config.caratDouble,
            day: _selDay!,
            month: _selMonth!,
            year: _selYear!,
          );

      if (!mounted) return;
      setState(() {
        _entries.add(
          _MonthPrice(
            selectedDate,
            result.checkDate,
            result.pastPrice,
            result.difference,
            currencyLocale: result.currencyLocale.isNotEmpty
                ? result.currencyLocale
                : 'en-IN',
            currencyCode: result.currencyCode.isNotEmpty
                ? result.currencyCode
                : 'INR',
          ),
        );
        _entries.sort((a, b) => a.month.compareTo(b.month));

        // Reset dropdowns after successful add
        _selYear = null;
        _selMonth = null;
        _selDay = null;
      });
    } catch (e, st) {
      debugPrint('❌ comparePastPrices error => $e');
      debugPrint('❌ stacktrace => $st');
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loadingMonth = false);
    }
  }

  void _removeEntry(int idx) => setState(() => _entries.removeAt(idx));

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16 * fem),
      child: Container(
        width: 780 * fem,
        constraints: BoxConstraints(maxHeight: 760 * fem),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * fem),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 40 * fem,
              offset: Offset(0, 12 * fem),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(28 * fem, 24 * fem, 28 * fem, 24 * fem),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 16 * fem),
            if (_entries.isEmpty) _buildEmptyState() else _buildChart(),
            if (_entries.isNotEmpty) ...[
              SizedBox(height: 12 * fem),
              _buildLegend(),
            ],
            if (_error != null) ...[
              SizedBox(height: 8 * fem),
              MyText(
                _error!,
                style: TextStyle(fontSize: 11 * fem, color: Color(0xFFE05050)),
              ),
            ],
            SizedBox(height: 16 * fem),
            _buildDateDropdowns(),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              'Compare Past Prices',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 17 * fem,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2A2A2A),
              ),
            ),
            SizedBox(height: 2 * fem),
            MyText(
              '${widget.config.shapeName} · ${widget.config.caratLabel}ct · ${widget.config.colorLabel} · ${widget.config.clarityLabel}',
              style: TextStyle(fontSize: 11 * fem, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 28 * fem,
            height: 28 * fem,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDDDDDD)),
            ),
            child: Icon(Icons.close, size: 14 * fem, color: Color(0xFF6B6B6B)),
          ),
        ),
      ],
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10 * fem),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 32 * fem,
              color: Colors.grey[300],
            ),
            SizedBox(height: 10 * fem),
            MyText(
              'Select a date below to compare past prices',
              style: TextStyle(fontSize: 12 * fem, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  // ── Chart ────────────────────────────────────────────────────────────────

  Widget _buildChart() {
    final cts = widget.config.caratDouble;
    final allPoints = List<_MonthPrice>.from(_entries)
      ..sort((a, b) => a.month.compareTo(b.month));

    return SizedBox(
      height: 280 * fem,
      child: CustomPaint(
        painter: _ChartPainter(
          points: allPoints,
          cts: cts,
          fem: fem,
          todayMonth: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ),
        ),
        child: Container(),
      ),
    );
  }

  // ── Legend ───────────────────────────────────────────────────────────────

  Widget _buildLegend() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ..._entries.asMap().entries.map((e) {
            final idx = e.key;
            final entry = e.value;
            final growth = entry.difference;
            final isNeg = growth < 0;
            final totalPrice = entry.price * widget.config.caratDouble;

            return Container(
              margin: EdgeInsets.only(right: 8 * fem),
              padding: EdgeInsets.all(10 * fem),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFAF3),
                borderRadius: BorderRadius.circular(8 * fem),
                border: Border.all(color: const Color(0xFFF0E6D0)),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -10,
                    right: -10,
                    child: GestureDetector(
                      onTap: () => _removeEntry(idx),
                      child: Container(
                        width: 18 * fem,
                        height: 18 * fem,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 10 * fem,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8 * fem, top: 2 * fem),
                        child: Icon(
                          Icons.show_chart,
                          size: 16 * fem,
                          color: _pointColor(idx),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            'Date: ${DateFormat('d MMM, yyyy').format(entry.checkDate)}',
                            style: TextStyle(
                              fontSize: 10 * fem,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          SizedBox(height: 3 * fem),
                          MyText(
                            'Price: ${_formatPrice(totalPrice)}',
                            style: TextStyle(
                              fontSize: 10 * fem,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          SizedBox(height: 3 * fem),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MyText(
                                'Growth: ',
                                style: TextStyle(
                                  fontSize: 10 * fem,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              MyText(
                                '${growth.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 10 * fem,
                                  fontWeight: FontWeight.w500,
                                  color: isNeg
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF22C55E),
                                ),
                              ),
                              SizedBox(width: 2 * fem),
                              Icon(
                                isNeg
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                size: 11 * fem,
                                color: isNeg
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF22C55E),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Date dropdowns row ───────────────────────────────────────────────────

  Widget _buildDateDropdowns() {
    final canAdd =
        !_loadingMonth &&
        _selYear != null &&
        _selMonth != null &&
        _selDay != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Year
        Expanded(
          child: _buildDropdown<int>(
            label: 'Year',
            value: _selYear,
            items: _years,
            itemLabel: (y) => '$y',
            enabled: true,
            onChanged: (y) => setState(() {
              _selYear = y;
              _selMonth = null;
              _selDay = null;
              _error = null;
            }),
          ),
        ),
        SizedBox(width: 8 * fem),

        // Month
        Expanded(
          child: _buildDropdown<int>(
            label: 'Month',
            value: _selMonth,
            items: _months,
            itemLabel: (m) => DateFormat('MMMM').format(DateTime(2000, m)),
            enabled: _selYear != null,
            onChanged: (m) => setState(() {
              _selMonth = m;
              _selDay = null;
              _error = null;
            }),
          ),
        ),
        SizedBox(width: 8 * fem),

        // Day
        Expanded(
          child: _buildDropdown<int>(
            label: 'Date',
            value: _selDay,
            items: _days,
            itemLabel: (d) => '$d',
            enabled: _selYear != null && _selMonth != null,
            onChanged: (d) => setState(() {
              _selDay = d;
              _error = null;
            }),
          ),
        ),
        SizedBox(width: 10 * fem),

        // Add button — bottom-aligned via CrossAxisAlignment.end on the Row
        // Compare Price button — bottom-aligned via CrossAxisAlignment.end on the Row
        SizedBox(
          height: 38 * fem,
          child: OutlinedButton.icon(
            onPressed: canAdd ? _fetchPrice : null,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 14 * fem),
              side: BorderSide(
                color: canAdd
                    ? const Color(0xFF5AB5A8)
                    : const Color(0xFFDDDDDD),
                width: 1.5 * fem,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10 * fem),
              ),
              backgroundColor: canAdd
                  ? const Color(0xFFE8F7F5)
                  : const Color(0xFFF5F5F5),
            ),
            icon: _loadingMonth
                ? SizedBox(
                    width: 14 * fem,
                    height: 14 * fem,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5 * fem,
                      color: Color(0xFF5AB5A8),
                    ),
                  )
                : Icon(
                    Icons.compare_arrows_rounded,
                    size: 16 * fem,
                    color: canAdd
                        ? const Color(0xFF5AB5A8)
                        : const Color(0xFFBBBBBB),
                  ),
            label: MyText(
              _loadingMonth ? 'Fetching…' : 'Compare Past Price',
              style: TextStyle(
                fontSize: 12 * fem,
                fontWeight: FontWeight.w500,
                fontFamily: 'Georgia',
                color: canAdd
                    ? const Color(0xFF5AB5A8)
                    : const Color(0xFFBBBBBB),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required bool enabled,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MyText(
          label,
          style: TextStyle(
            fontSize: 10 * fem,
            fontWeight: FontWeight.w500,
            color: enabled ? const Color(0xFF6B6B6B) : const Color(0xFFBBBBBB),
          ),
        ),
        SizedBox(height: 4 * fem),
        Container(
          height: 38 * fem,
          padding: EdgeInsets.symmetric(horizontal: 10 * fem),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8 * fem),
            border: Border.all(
              color: enabled
                  ? const Color(0xFFBEE4DD)
                  : const Color(0xFFEEEEEE),
              width: 1.2 * fem,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: MyText(
                'Select',
                style: TextStyle(
                  fontSize: 12 * fem,
                  color: const Color(0xFFBBBBBB),
                ),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16 * fem,
                color: enabled
                    ? const Color(0xFF5AB5A8)
                    : const Color(0xFFCCCCCC),
              ),
              style: TextStyle(
                fontSize: 12 * fem,
                color: const Color(0xFF2A2A2A),
                fontFamily: 'Georgia',
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(10 * fem),
              onChanged: enabled ? onChanged : null,
              items: items
                  .map(
                    (item) => DropdownMenuItem<T>(
                      value: item,
                      child: MyText(
                        itemLabel(item),
                        style: TextStyle(
                          fontSize: 12 * fem,
                          color: const Color(0xFF2A2A2A),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Color _pointColor(int idx) {
    const palette = [
      Color(0xFF5AB5A8),
      Color(0xFFC8AC7D),
      Color(0xFF9898D0),
      Color(0xFFE05050),
      Color(0xFF4CAF50),
      Color(0xFF2196F3),
    ];
    return palette[idx % palette.length];
  }

  String _formatPrice(double p) {
    final v = p.round();
    final lakh = v ~/ 100000;
    final rem = v % 100000;
    final th = rem ~/ 1000;
    final hu = rem % 1000;
    if (lakh > 0) {
      return '₹$lakh,${th.toString().padLeft(2, '0')},${hu.toString().padLeft(3, '0')}';
    }
    if (v >= 1000) {
      return '₹${th.toString()},${hu.toString().padLeft(3, '0')}';
    }
    return '₹$v';
  }
}

// ---------------------------------------------------------------------------
// Chart painter — draws real data
// ---------------------------------------------------------------------------
class _ChartPainter extends CustomPainter {
  final List<_MonthPrice> points;
  final DateTime todayMonth;
  final double cts;
  final double fem;

  const _ChartPainter({
    required this.points,
    required this.todayMonth,
    required this.cts,
    required this.fem,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      if (points.length == 1) _drawSinglePoint(canvas, size, points.first);
      return;
    }

    final leftPad = 68.0 * fem;
    final rightPad = 16.0 * fem;
    final topPad = 32.0 * fem;
    final botPad = 28.0 * fem;
    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - botPad;

    final minP = points.map((e) => e.price * cts).reduce(math.min);
    final maxP = points.map((e) => e.price * cts).reduce(math.max);
    final range = (maxP - minP).clamp(1.0, double.infinity);

    Offset toOffset(int i) {
      final x = leftPad + (i / (points.length - 1)) * chartW;
      final y = topPad + (1 - (points[i].price * cts - minP) / range) * chartH;
      return Offset(x, y);
    }

    final offsets = List.generate(points.length, toOffset);

    // Grid
    final gridPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 0.8 * fem;
    for (int i = 1; i < 5; i++) {
      final y = topPad + chartH * i / 4;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(leftPad + chartW, y),
        gridPaint,
      );
    }

    final labelStyle = TextStyle(fontSize: 11 * fem, color: Color(0xFFAAAAAA));
    for (int i = 0; i <= 4; i++) {
      final price = minP + (maxP - minP) * i / 4;
      final y = topPad + chartH * (1 - i / 4);
      final text = _shortPrice(price);
      final tp = TextPainter(
        text: TextSpan(text: text, style: labelStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 6, y - tp.height / 2));
    }

    // Gradient fill
    final gradPath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 1; i < offsets.length; i++) {
      _addCurve(gradPath, offsets[i - 1], offsets[i]);
    }
    gradPath
      ..lineTo(offsets.last.dx, topPad + chartH)
      ..lineTo(offsets.first.dx, topPad + chartH)
      ..close();

    canvas.drawPath(
      gradPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF5AB5A8).withOpacity(0.3),
            const Color(0xFF5AB5A8).withOpacity(0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    final linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 1; i < offsets.length; i++) {
      _addCurve(linePath, offsets[i - 1], offsets[i]);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xFF5AB5A8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // X-axis labels + dots
    const palette = [
      Color(0xFF5AB5A8),
      Color(0xFFC8AC7D),
      Color(0xFF9898D0),
      Color(0xFFE05050),
      Color(0xFF4CAF50),
      Color(0xFF2196F3),
    ];
    for (int i = 0; i < offsets.length; i++) {
      final pt = points[i];
      final off = offsets[i];
      final isToday =
          pt.month.year == todayMonth.year &&
          pt.month.month == todayMonth.month &&
          pt.month.day == todayMonth.day;
      final color = isToday
          ? const Color(0xFF2A2A2A)
          : palette[i % palette.length];

      canvas.drawCircle(off, 7 * fem, Paint()..color = Colors.white);
      canvas.drawCircle(
        off,
        7 * fem,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );

      _drawTooltip(canvas, off, _shortPrice(pt.price * cts), color);

      final label = isToday ? 'Today' : pt.label;
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(fontSize: 11 * fem, color: color),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(off.dx - tp.width / 2, topPad + chartH + 6));
    }
  }

  void _addCurve(Path path, Offset a, Offset b) {
    final cpx = (a.dx + b.dx) / 2;
    path.cubicTo(cpx, a.dy, cpx, b.dy, b.dx, b.dy);
  }

  void _drawTooltip(Canvas canvas, Offset pos, String text, Color color) {
    const tipH = 24.0;
    const padH = 10.0;
    const rr = 5.0;

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 11 * fem,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final tipW = tp.width + padH * 2;
    final left = pos.dx - tipW / 2;
    final top = pos.dy - tipH - 10;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, tipW, tipH),
      const Radius.circular(rr),
    );

    canvas.drawRRect(rect, Paint()..color = Colors.white);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    tp.paint(canvas, Offset(left + padH, top + (tipH - tp.height) / 2));
  }

  void _drawSinglePoint(Canvas canvas, Size size, _MonthPrice pt) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      center,
      7 * fem,
      Paint()
        ..color = const Color(0xFF5AB5A8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    _drawTooltip(
      canvas,
      center,
      _shortPrice(pt.price * cts),
      const Color(0xFF5AB5A8),
    );
  }

  String _shortPrice(double p) {
    if (p >= 100000) return '₹${(p / 100000).toStringAsFixed(1)}L';
    if (p >= 1000) return '₹${(p / 1000).toStringAsFixed(1)}K';
    return '₹${p.toStringAsFixed(0)}';
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.points != points || old.cts != cts || old.fem != fem;
}
