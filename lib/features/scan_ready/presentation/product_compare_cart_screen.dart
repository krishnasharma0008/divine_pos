import 'package:divine_pos/features/scan_ready/data/product_model.dart';
import 'package:divine_pos/features/scan_ready/provider/scan_ready_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'scan_ready_product_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProductCompareCartScreen
// ─────────────────────────────────────────────────────────────────────────────

class ProductCompareCartScreen extends ConsumerStatefulWidget {
  final List<ProductModel> initialProducts;

  const ProductCompareCartScreen({super.key, this.initialProducts = const []});

  @override
  ConsumerState<ProductCompareCartScreen> createState() =>
      _ProductCompareCartScreenState();
}

class _ProductCompareCartScreenState
    extends ConsumerState<ProductCompareCartScreen> {
  late List<ProductModel> _products;

  bool _showBreakup = false;

  static const Color _bg = Color(0xFFF5F3EF);
  static const Color _teal = Color(0xFF2BAFA0);

  @override
  void initState() {
    super.initState();
    _products = List.from(widget.initialProducts);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  // String _uniqueKey(ProductModel p) =>
  //     (p.itemno ?? p.designno ?? p.id.toString()).trim();
  String _uniqueKey(ProductModel p) {
    final key = p.itemno?.trim().isNotEmpty == true
        ? p.itemno!.trim()
        : p.designno?.trim().isNotEmpty == true
        ? p.designno!.trim()
        : p.id?.toString() ?? '';

    return key;
  }

  void _removeProduct(int index) {
    final removed = _products[index];
    setState(() => _products.removeAt(index));
    // Keep the provider list in sync so future scans de-duplicate correctly.
    ref.read(scanReadyProvider.notifier).removeProduct(removed);
  }

  void _openScanPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScanPopup(
        onDetected: (product) {
          // Close the scan sheet.
          if (Navigator.canPop(context)) Navigator.pop(context);

          final alreadyExists = _products.any(
            (e) => _uniqueKey(e) == _uniqueKey(product),
          );

          if (alreadyExists) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This product is already in the comparison.'),
              ),
            );
            return;
          }

          setState(() {
            _products.add(product);
          });

          // setState(() {
          //   if (!_products.any((e) => _uniqueKey(e) == _uniqueKey(product))) {
          //     _products.add(product);
          //   } else {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(
          //         content: Text('This product is already in the comparison.'),
          //       ),
          //     );
          //   }
          // });
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Row / section definitions
  // ---------------------------------------------------------------------------

  List<_RowDef> get _mainRows => [
    _RowDef('MRP', (p) {
      if (p.productAmtMax != null && p.productAmtMax! > 0) {
        return '₹${_fmtIndian(p.productAmtMax!)}';
      }
      return '—';
    }, bold: true),
    _RowDef('Solitaire weight', (p) => _v(p.solitaireSlab)),
    _RowDef(
      'Metal weight',
      (p) => p.metalWeight != null ? '${p.metalWeight} g' : '—',
    ),
    _RowDef('UID', (p) => _v(p.itemno)),
    _RowDef('Design number', (p) => _v(p.designno)),
  ];

  List<_SectionDef> get _breakupSections => [
    _SectionDef('SOLITAIRE BREAKUP', [
      _RowDef('Cut / Shape', (p) => _v(p.solitaireShape)),
      _RowDef('Color', (p) => _v(p.solitaireColor)),
      _RowDef('Clarity', (p) => _v(p.solitaireQuality)),
      _RowDef(
        'Pieces',
        (p) => p.solitairePcs != null && p.solitairePcs! > 0
            ? '${p.solitairePcs} pcs'
            : '—',
      ),
      _RowDef('Amount', (p) {
        if (p.solitaireAmtMax != null && p.solitaireAmtMax! > 0) {
          return '₹${_fmtIndian(p.solitaireAmtMax!)}';
        }
        return '—';
      }),
    ]),
    _SectionDef('METAL BREAKUP', [
      _RowDef('Metal type', (p) {
        final parts = [
          p.metalType,
          p.metalColor,
        ].where((s) => s != null && s.isNotEmpty).join(' ');
        return parts.isNotEmpty ? parts : '—';
      }),
      _RowDef('Purity', (p) => _v(p.metalPurity)),
      _RowDef(
        'Weight',
        (p) => p.metalWeight != null ? '${p.metalWeight} g' : '—',
      ),
      _RowDef('Price', (p) {
        if (p.metalPrice != null && p.metalPrice! > 0) {
          return '₹${_fmtIndian(p.metalPrice!)}';
        }
        return '—';
      }),
    ]),
    _SectionDef('SIDE DIAMONDS', [
      _RowDef(
        'Count',
        (p) => p.sideStonePcs != null && p.sideStonePcs! > 0
            ? '${p.sideStonePcs} pcs'
            : '—',
      ),
      _RowDef(
        'Total weight',
        (p) => p.sideStoneCtw != null && p.sideStoneCtw! > 0
            ? '${p.sideStoneCtw} ct'
            : '—',
      ),
      _RowDef('Color', (p) => _v(p.sideStoneColor)),
      _RowDef('Clarity', (p) => _v(p.sideStoneQuality)),
    ]),
  ];

  String _v(String? s) {
    final t = s?.trim() ?? '';
    return t.isNotEmpty ? t : '—';
  }

  String _fmtIndian(double v) {
    final s = v.toStringAsFixed(0);
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
      buf.write(rest[i]);
    }
    return '${buf.toString()},$last3';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _products.isEmpty ? _buildEmpty() : _buildTableView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            //onTap: () => Navigator.pop(context), back button should also clear the provider state to avoid stale products on next open
            onTap: () {
              ref.read(scanReadyProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 17,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Compare jewelry',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      TextSpan(
                        text:
                            '  ·  ${_products.length} item${_products.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'Tap "+ Add Product" to compare more',
                  style: TextStyle(fontSize: 11, color: Color(0xFFBBBBBB)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _openScanPopup,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.white, size: 14),
                  SizedBox(width: 5),
                  Text(
                    'Scan product',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  Widget _buildTableView() {
    return Column(
      children: [
        Expanded(
          child: _CompareTable(
            products: _products,
            mainRows: _mainRows,
            breakupSections: _breakupSections,
            showBreakup: _showBreakup,
            // ✅ FIX: route remove through the dedicated helper so the
            // provider stays in sync without touching clearAll().
            onRemove: _removeProduct,
            onAddProduct: _openScanPopup,
          ),
        ),
        _buildToggle(),
      ],
    );
  }

  Widget _buildToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: GestureDetector(
        onTap: () => setState(() => _showBreakup = !_showBreakup),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2DDD8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _showBreakup ? 'Hide breakup' : 'Show full breakup',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF444444),
                ),
              ),
              const SizedBox(width: 5),
              AnimatedRotation(
                turns: _showBreakup ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 17,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.compare_arrows_rounded, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 14),
          Text(
            'No products to compare',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _openScanPopup,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: _teal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Scan a product',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────────────────────────────────────

class _RowDef {
  final String label;
  final String Function(ProductModel) value;
  final bool bold;
  const _RowDef(this.label, this.value, {this.bold = false});
}

class _SectionDef {
  final String title;
  final List<_RowDef> rows;
  const _SectionDef(this.title, this.rows);
}

// ─────────────────────────────────────────────────────────────────────────────
// _CompareTable
// ─────────────────────────────────────────────────────────────────────────────

class _CompareTable extends StatefulWidget {
  final List<ProductModel> products;
  final List<_RowDef> mainRows;
  final List<_SectionDef> breakupSections;
  final bool showBreakup;
  final void Function(int) onRemove;
  final VoidCallback onAddProduct;

  const _CompareTable({
    required this.products,
    required this.mainRows,
    required this.breakupSections,
    required this.showBreakup,
    required this.onRemove,
    required this.onAddProduct,
  });

  @override
  State<_CompareTable> createState() => _CompareTableState();
}

class _CompareTableState extends State<_CompareTable> {
  final _hScroll = ScrollController();
  final _vScroll = ScrollController();

  // ── Layout constants ──────────────────────────────────────────────────────
  static const double _labelColW = 130.0;

  // ✅ FIX: Reduced from 150 → 110 so product columns are more compact;
  // combined with the sticky Add column this avoids unnecessary side-scrolling
  // when there is only one product.
  static const double _minColW = 110.0;

  // ✅ FIX (new): dedicated width for the always-visible "Add Product" column.
  // Previously the add column lived inside the horizontal scroll, so it could
  // be pushed off-screen by 3+ product columns.  Now it is pinned to the
  // right edge of the table and is always accessible without scrolling.
  static const double _addColW = 80.0;

  static const double _headerH = 104.0;
  static const double _rowH = 44.0;
  static const double _sectionH = 30.0;

  static const Color _teal = Color(0xFF2BAFA0);
  static const Color _tealLight = Color(0xFFE0F5F2);
  static const Color _border = Color(0xFFE2DDD8);
  static const Color _labelBg = Color(0xFFF7F5F2);
  static const Color _sectionBg = Color(0xFFEEEBE6);
  static const Color _addColBg = Color(0xFFFAFAFA);
  static const Color _white = Colors.white;

  @override
  void dispose() {
    _hScroll.dispose();
    _vScroll.dispose();
    super.dispose();
  }

  int get _count => widget.products.length;

  // ✅ FIX: Compute column width for PRODUCT columns only.
  // The Add column is now a fixed sticky column, so we exclude it from the
  // available-width calculation.
  //
  // Formula (all in logical pixels):
  //   screen
  //   − left-margin(16) − right-margin(16)   ← Container margin
  //   − left-border(1)  − right-border(1)    ← Border.all()
  //   − labelColW(130)  − label-divider(1)   ← fixed label column
  //   − add-divider(1)  − addColW(80)        ← fixed add column
  //   = available space for the horizontal product scroll
  double _colW(BuildContext context) {
    final screen = MediaQuery.of(context).size.width;
    const overhead =
        16.0 +
        16.0 + // horizontal margin
        1.0 +
        1.0 + // border left + right
        _labelColW +
        1.0 + // label col + its right divider
        1.0 +
        _addColW; // add col's left divider + add col
    final available = screen - overhead;
    if (_count <= 0 || available <= 0) return _minColW;
    final each = available / _count;
    return each >= _minColW ? each : _minColW;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colW = _colW(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        // Outer vertical scroll keeps label, products, and add-col in sync.
        child: SingleChildScrollView(
          controller: _vScroll,
          physics: const ClampingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Fixed: label column ──────────────────────────────────────
              SizedBox(width: _labelColW, child: _buildLabelColumn()),
              Container(width: 1, color: _border),

              // ── Scrollable: product columns only ─────────────────────────
              // ✅ FIX: Expanded fills remaining width between the two fixed
              // columns (label & add).  The horizontal SingleChildScrollView
              // inside lets the user swipe through 3+ product columns without
              // the Add button ever going off-screen.
              Expanded(
                child: SingleChildScrollView(
                  controller: _hScroll,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < _count; i++) ...[
                        if (i > 0) Container(width: 1, color: _border),
                        SizedBox(width: colW, child: _buildProductColumn(i)),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Fixed: "Add Product" column – always visible ─────────────
              // ✅ FIX: Extracted from the horizontal scroll.  No matter how
              // many products are added, this column stays pinned at the right
              // edge and is never cut off.
              Container(width: 1, color: _border),
              SizedBox(width: _addColW, child: _buildAddProductColumn()),
            ],
          ),
        ),
      ),
    );
  }

  // ── Column builders ───────────────────────────────────────────────────────

  Widget _buildLabelColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lh(_headerH, child: const SizedBox.shrink()),
        for (final row in widget.mainRows) _lc(row.label),
        if (widget.showBreakup)
          for (final sec in widget.breakupSections) ...[
            _ls(sec.title),
            for (final row in sec.rows) _lc(row.label),
          ],
      ],
    );
  }

  Widget _buildProductColumn(int index) {
    final p = widget.products[index];
    return Column(
      children: [
        _ph(_headerH, p: p, index: index),
        for (final row in widget.mainRows) _vc(row.value(p), bold: row.bold),
        if (widget.showBreakup)
          for (final sec in widget.breakupSections) ...[
            _vs(),
            for (final row in sec.rows) _vc(row.value(p)),
          ],
      ],
    );
  }

  // ✅ FIX: _buildAddProductColumn now renders in _addColW (80 dp) instead of
  // the full colW.  The circle and text are scaled down to fit cleanly.
  Widget _buildAddProductColumn() {
    final dataRowCount = widget.mainRows.length;

    return Column(
      children: [
        GestureDetector(
          onTap: widget.onAddProduct,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: _headerH,
            decoration: const BoxDecoration(
              color: _addColBg,
              border: Border(bottom: BorderSide(color: _border)),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _tealLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: _teal, width: 1.5),
                  ),
                  child: const Icon(Icons.add, color: _teal, size: 22),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Add\nProduct',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    color: _teal,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        for (int i = 0; i < dataRowCount; i++) _emptyCell(),
        if (widget.showBreakup)
          for (final sec in widget.breakupSections) ...[
            _emptySectionCell(),
            for (int i = 0; i < sec.rows.length; i++) _emptyCell(),
          ],
      ],
    );
  }

  // ── Cell builders ─────────────────────────────────────────────────────────

  Widget _lh(double h, {required Widget child}) {
    return Container(
      height: h,
      width: double.infinity,
      color: _labelBg,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: child,
    );
  }

  Widget _lc(String label) {
    return Container(
      height: _rowH,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: _labelBg,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 11.5,
          color: Color(0xFF555555),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _ls(String title) {
    return Container(
      height: _sectionH,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: _sectionBg,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Color(0xFF999990),
        ),
      ),
    );
  }

  Widget _ph(double h, {required ProductModel p, required int index}) {
    return Container(
      height: h,
      width: double.infinity,
      color: _white,
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 20, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _thumbnail(p),
                  const SizedBox(height: 6),
                  Text(
                    _name(p),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => widget.onRemove(index),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCCCCCC)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  size: 12,
                  color: Color(0xFF888888),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(height: 1, color: _border),
          ),
        ],
      ),
    );
  }

  Widget _vc(String value, {bool bold = false}) {
    final empty = value == '—';
    return Container(
      height: _rowH,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: _white,
        border: Border(top: BorderSide(color: _border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        value,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: bold ? 12.5 : 11.5,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: empty
              ? const Color(0xFFCCCCCC)
              : bold
              ? const Color(0xFF1A1A1A)
              : const Color(0xFF444444),
        ),
      ),
    );
  }

  Widget _vs() {
    return Container(
      height: _sectionH,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _sectionBg,
        border: Border(top: BorderSide(color: _border)),
      ),
    );
  }

  Widget _emptyCell() {
    return Container(
      height: _rowH,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _addColBg,
        border: Border(top: BorderSide(color: _border)),
      ),
    );
  }

  Widget _emptySectionCell() {
    return Container(
      height: _sectionH,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _sectionBg,
        border: Border(top: BorderSide(color: _border)),
      ),
    );
  }

  Widget _thumbnail(ProductModel p) {
    final url = p.imageUrl?.trim() ?? '';
    if (url.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          url,
          width: 54,
          height: 54,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _icon(p),
        ),
      );
    }
    return _icon(p);
  }

  Widget _icon(ProductModel p) {
    final cat = (p.productSubCategory ?? p.productCategory ?? '').toLowerCase();
    Color bg, fg;
    IconData icon;
    if (cat.contains('ring')) {
      bg = const Color(0xFFF5E8D5);
      fg = const Color(0xFFB8863A);
      icon = Icons.circle_outlined;
    } else if (cat.contains('stud') || cat.contains('ear')) {
      bg = const Color(0xFFE8E8E8);
      fg = const Color(0xFF666666);
      icon = Icons.stop_rounded;
    } else if (cat.contains('pendant') || cat.contains('drop')) {
      bg = const Color(0xFFFDE8F0);
      fg = const Color(0xFFD4489A);
      icon = Icons.diamond_outlined;
    } else if (cat.contains('nose')) {
      bg = const Color(0xFFFFF3E0);
      fg = const Color(0xFFE6891A);
      icon = Icons.circle;
    } else if (cat.contains('bangle') || cat.contains('bracelet')) {
      bg = const Color(0xFFE8F0FF);
      fg = const Color(0xFF3A6AB8);
      icon = Icons.circle_outlined;
    } else if (cat.contains('chain') || cat.contains('necklace')) {
      bg = const Color(0xFFEDE7F6);
      fg = const Color(0xFF7B1FA2);
      icon = Icons.link;
    } else {
      bg = const Color(0xFFE0F5F2);
      fg = _teal;
      icon = Icons.diamond;
    }
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 24, color: fg),
    );
  }

  String _name(ProductModel p) {
    final sub = p.productSubCategory?.trim() ?? '';
    if (sub.isNotEmpty) return _tc(sub);
    final cat = p.productCategory?.trim() ?? '';
    if (cat.isNotEmpty) return _tc(cat);
    return p.designno ?? '#${p.id}';
  }

  String _tc(String s) => s
      .split(' ')
      .map(
        (w) => w.isEmpty
            ? ''
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
      )
      .join(' ');
}
