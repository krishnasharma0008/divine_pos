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
  final DateTime month; // selected month (for sorting/dedup)
  final DateTime checkDate; // actual check_date from API response
  final double price; // per-carat price from API — display as price * cts
  final double difference; // % growth string from API e.g. "-18.5"
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

  String get label => DateFormat('MMM yy').format(month);
}

// ---------------------------------------------------------------------------
// Modal
// ---------------------------------------------------------------------------
class PriceChartModal extends ConsumerStatefulWidget {
  final DiamondConfig config;
  final double? currentPrice; // today's price passed in from screen

  const PriceChartModal({super.key, required this.config, this.currentPrice});

  @override
  ConsumerState<PriceChartModal> createState() => _PriceChartModalState();
}

class _PriceChartModalState extends ConsumerState<PriceChartModal> {
  final List<_MonthPrice> _entries = [];
  bool _loadingMonth = false;
  String? _error;

  double get fem => ScaleSize.aspectRatio;

  // -------------------------------------------------------------------------
  // Show month picker then fetch price for selected month
  // -------------------------------------------------------------------------
  Future<void> _pickAndFetch() async {
    final now = DateTime.now();

    // Custom month-year picker — Flutter's showDatePicker can't do month-only
    final selected = await _showMonthYearPicker(
      initialYear: now.year,
      minYear: 2012,
      maxYear: now.year,
      currentMonth: now.month,
    );

    if (selected == null || !mounted) return;

    final selectedMonth = selected;

    // Prevent duplicates — show inline message instead of snack
    if (_entries.any(
      (e) =>
          e.month.year == selectedMonth.year &&
          e.month.month == selectedMonth.month,
    )) {
      setState(
        () => _error =
            '${DateFormat('MMMM yyyy').format(selectedMonth)} is already added. Please select a different month.',
      );
      return;
    }

    setState(() {
      _loadingMonth = true;
      _error = null;
    });

    try {
      // mirrors JS fetchComparisonData → comparePastPrices(state, countrycode)
      // state = { shape, colour, clarity, cts, month, year, day }
      final result = await ref
          .read(diamondPriceRepositoryProvider)
          .comparePastPrices(
            shape: widget.config.shapeCode,
            colour: widget.config.colorLabel,
            clarity: widget.config.clarityLabel,
            cts: widget.config.caratDouble,
            month: selectedMonth.month,
            year: selectedMonth.year,
          );

      if (!mounted) return;
      setState(() {
        _entries.add(
          _MonthPrice(
            selectedMonth,
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

  // Custom month-year picker — proper month selection like JS ReactDatePicker
  Future<DateTime?> _showMonthYearPicker({
    required int initialYear,
    required int minYear,
    required int maxYear,
    required int currentMonth,
  }) async {
    final now = DateTime.now();
    int selectedYear = initialYear;

    return await showDialog<DateTime>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16 * fem),
        ),
        child: StatefulBuilder(
          builder: (ctx, setModal) {
            final months = [
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
            ];
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20 * fem,
                16 * fem,
                20 * fem,
                28 * fem,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36 * fem,
                    height: 4 * fem,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(2 * fem),
                    ),
                  ),
                  SizedBox(height: 16 * fem),
                  MyText(
                    'Select Month',
                    style: TextStyle(
                      fontSize: 15 * fem,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
                  SizedBox(height: 16 * fem),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: selectedYear > minYear
                            ? () => setModal(() => selectedYear--)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                        color: const Color(0xFF5AB5A8),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          '$selectedYear',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18 * fem,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2A2A2A),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: selectedYear < maxYear
                            ? () => setModal(() => selectedYear++)
                            : null,
                        icon: const Icon(Icons.chevron_right),
                        color: const Color(0xFF5AB5A8),
                      ),
                    ],
                  ),
                  SizedBox(height: 12 * fem),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 2.2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: 12,
                    itemBuilder: (_, i) {
                      final mNum = i + 1;
                      final isFuture =
                          selectedYear == now.year && mNum > now.month;
                      final isSelected =
                          mNum == now.month - 1; // just for initial highlight
                      return GestureDetector(
                        onTap: isFuture
                            ? null
                            : () => Navigator.pop(
                                ctx,
                                DateTime(selectedYear, mNum),
                              ),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isFuture
                                ? const Color(0xFFF0F0F0)
                                : const Color(0xFFE8F7F5),
                            borderRadius: BorderRadius.circular(8 * fem),
                          ),
                          child: Text(
                            months[i],
                            style: TextStyle(
                              fontSize: 13 * fem,
                              fontWeight: FontWeight.w500,
                              color: isFuture
                                  ? const Color(0xFFBBBBBB)
                                  : const Color(0xFF2A2A2A),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(32 * fem),
      child: Container(
        width: 620 * fem,
        constraints: BoxConstraints(maxHeight: 600 * fem),
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
              Text(
                _error!,
                style: TextStyle(fontSize: 11 * fem, color: Color(0xFFE05050)),
              ),
            ],
            SizedBox(height: 16 * fem),
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

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
            Text(
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

  Widget _buildCurrentPrice() {
    if (widget.currentPrice == null) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * fem, vertical: 10 * fem),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7F5),
        borderRadius: BorderRadius.circular(8 * fem),
        border: Border.all(color: const Color(0xFFBEE4DD)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyText(
            'Today  ',
            style: TextStyle(fontSize: 12 * fem, color: Color(0xFF5AB5A8)),
          ),
          MyText(
            _formatPrice(widget.currentPrice! * widget.config.caratDouble),
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 20 * fem,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2A2A2A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 180,
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
            Text(
              'Tap "Add Month" to compare past prices',
              style: TextStyle(fontSize: 12 * fem, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final cts = widget.config.caratDouble;
    final allPoints = List<_MonthPrice>.from(_entries)
      ..sort((a, b) => a.month.compareTo(b.month));

    return SizedBox(
      height: 200 * fem,
      child: CustomPaint(
        painter: _ChartPainter(
          points: allPoints,
          cts: cts,
          fem: fem,
          todayMonth: DateTime(DateTime.now().year, DateTime.now().month),
        ),
        child: Container(),
      ),
    );
  }

  Widget _buildLegend() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ..._entries.asMap().entries.map((e) {
            final idx = e.key;
            final entry = e.value;
            final growth =
                entry.difference; // from API — mirrors JS priceItem.growth
            final isNeg = growth < 0;
            final totalPrice =
                entry.price *
                widget.config.caratDouble; // mirrors JS parseInt(price) * cts

            return Container(
              margin: EdgeInsets.only(right: 10 * fem * fem),
              padding: EdgeInsets.all(12 * fem),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFAF3), // matches JS bg-[#fffaf3]
                borderRadius: BorderRadius.circular(8 * fem),
                border: Border.all(color: const Color(0xFFF0E6D0)),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // X remove button — top right, mirrors JS XIcon absolute -right-2 -top-2
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
                          size: 11 * fem,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chart icon — mirrors JS <ChartLineUpIcon />
                      Padding(
                        padding: EdgeInsets.only(right: 10 * fem, top: 2 * fem),
                        child: Icon(
                          Icons.show_chart,
                          size: 20 * fem,
                          color: _pointColor(idx),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date: MMM, YYYY — mirrors JS dayjs(date).format("MMM, YYYY")
                          Text(
                            'Date: ${DateFormat('MMM, yyyy').format(entry.checkDate)}',
                            style: TextStyle(
                              fontSize: 12 * fem,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          SizedBox(height: 4 * fem),
                          // Price: past_price * cts — mirrors JS parseInt(price) * cts
                          Text(
                            'Price: ${_formatPrice(totalPrice)}',
                            style: TextStyle(
                              fontSize: 12 * fem,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          SizedBox(height: 4 * fem),
                          // Growth: X% with red/green + arrow — mirrors JS ArrowUpIcon/ArrowDownIcon
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Growth: ',
                                style: TextStyle(
                                  fontSize: 12 * fem,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              Text(
                                '${growth.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 12 * fem,
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
                                size: 13 * fem,
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

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _loadingMonth ? null : _pickAndFetch,
        icon: _loadingMonth
            ? SizedBox(
                width: 14 * fem,
                height: 14 * fem,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5 * fem,
                  color: Color(0xFF5AB5A8),
                ),
              )
            : Icon(Icons.add, size: 16 * fem, color: Color(0xFF5AB5A8)),
        label: Text(
          _loadingMonth ? 'Fetching…' : 'Add Month',
          style: TextStyle(
            fontSize: 13 * fem,
            color: Color(0xFF5AB5A8),
            fontFamily: 'Georgia',
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Color(0xFFBEE4DD), width: 1.5 * fem),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10 * fem),
          ),
          padding: EdgeInsets.symmetric(vertical: 12 * fem),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------
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
  final double fem; // ScaleSize.aspectRatio passed from widget

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

    final leftPad = 56.0 * fem;
    final rightPad = 16.0 * fem;
    final topPad = 24.0 * fem;
    final botPad = 24.0 * fem;
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

    // Y axis labels
    final labelStyle = TextStyle(fontSize: 9 * fem, color: Color(0xFFAAAAAA));
    for (int i = 0; i <= 4; i++) {
      final price = minP + (maxP - minP) * i / 4;
      final y = topPad + chartH * (1 - i / 4);
      final text = _shortPrice(price);
      final tp = TextPainter(
        text: TextSpan(text: text, style: labelStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 4, y - tp.height / 2));
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
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // X axis labels + dots
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
          pt.month.month == todayMonth.month;
      final color = isToday
          ? const Color(0xFF2A2A2A)
          : palette[i % palette.length];

      // Dot
      canvas.drawCircle(off, 5 * fem, Paint()..color = Colors.white);
      canvas.drawCircle(
        off,
        5 * fem,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Tooltip above dot
      _drawTooltip(canvas, off, _shortPrice(pt.price * cts), color);

      // X label
      final label = isToday ? 'Today' : pt.label;
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(fontSize: 9 * fem, color: color),
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
    const tipH = 20.0;
    const padH = 8.0;
    const rr = 4.0;

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 9 * fem,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final tipW = tp.width + padH * 2;
    final left = pos.dx - tipW / 2;
    final top = pos.dy - tipH - 8;
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
      6 * fem,
      Paint()
        ..color = const Color(0xFF5AB5A8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
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
