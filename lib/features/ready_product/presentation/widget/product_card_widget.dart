import 'package:divine_pos/features/ready_product/data/product_model.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onRemove;

  /// Called when the user taps "Add To Cart". Pass null to hide the button.
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onRemove,
    this.onAddToCart,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _expanded = false;

  static const Color _teal = Color(0xFF2BAFA0);
  static const Color _tealLight = Color(0xFFE0F5F2);
  static const Color _labelColor = Color(0xFF333333);
  static const Color _valueColor = Color(0xFF555555);

  // ── Indian rupee formatter ───────────────────────────────────────────────

  String _formatINR(double? amount) {
    if (amount == null || amount <= 0) return '—';
    final val = amount.toInt();
    final s = val.toString();
    if (s.length <= 3) return '₹$s';

    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    for (var i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
      buf.write(rest[i]);
    }
    return '₹${buf.toString()},$last3';
  }

  // ── Derived display values ───────────────────────────────────────────────

  String get _displayPrice {
    final price = widget.product.productAmtMax;
    return _formatINR(price);
  }

  String get _uid =>
      _notEmpty(widget.product.itemno) ??
      _notEmpty(widget.product.designno) ??
      '—';

  String? _notEmpty(String? s) {
    final t = s?.trim() ?? '';
    return t.isNotEmpty ? t : null;
  }

  String? get _solitaireLine {
    final parts = <String>[];
    if (_notEmpty(widget.product.solitaireShape) != null) {
      parts.add(widget.product.solitaireShape!);
    }
    final slab = widget.product.solitaireSlab?.split('-').first.trim() ?? '';
    if (slab.isNotEmpty) parts.add('${slab}ct');
    final col = widget.product.solitaireColor?.trim() ?? '';
    final qual = widget.product.solitaireQuality?.trim() ?? '';
    final cq = [col, qual].where((e) => e.isNotEmpty).join(' ');
    if (cq.isNotEmpty) parts.add(cq);
    return parts.isEmpty ? null : parts.join(', ');
  }

  // '${p.netWt} gms | ${p.mountDetails1} ',
  String? get _mountLine {
    final parts = <String>[];
    List<String> metail = widget.product.mountDetails1?.split(' ') ?? [];
    final purity = metail[1] + ' ' + metail[2] ?? '';
    final color = metail[3].trim() ?? '';
    final type = metail[0].trim() ?? '';
    final metalDesc = [
      purity,
      color,
      type,
    ].where((e) => e.isNotEmpty).join(' ');
    if (metalDesc.isNotEmpty) parts.add('Metal-$metalDesc');
    final wt = widget.product.metalWeight;
    if (wt != null && wt > 0) parts.add('${wt.toStringAsFixed(2)}gms');
    return parts.isEmpty ? null : parts.join(', ');
  }

  String? get _sideDiamondsLine {
    final pcs = widget.product.sideStonePcs;
    final ctw = widget.product.sideStoneCtw;
    if ((pcs == null || pcs == 0) && (ctw == null || ctw == 0)) return null;

    final parts = <String>[];
    if (pcs != null && pcs > 0) parts.add('${pcs}Pcs');
    if (ctw != null && ctw > 0) parts.add('${ctw}ct');
    final col = widget.product.sideStoneColor?.trim() ?? '';
    final qual = widget.product.sideStoneQuality?.trim() ?? '';
    final cq = [col, qual].where((e) => e.isNotEmpty).join(' ');
    if (cq.isNotEmpty) parts.add(cq);
    return parts.isEmpty ? null : parts.join(', ');
  }

  String? get _sizeLine {
    final from = widget.product.sizeFrom?.trim() ?? '';
    final to = widget.product.sizeTo?.trim() ?? '';
    if (from.isEmpty && to.isEmpty) return null;
    if (to.isEmpty || from == to) return from;
    return '$from–$to';
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        //color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
          colors: [const Color(0xFFF9F9F9), const Color(0xFFF6F6F6)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildImageSection(), _buildInfoSection()],
      ),
    );
  }

  // ── Image section ────────────────────────────────────────────────────────

  Widget _buildImageSection() {
    return Stack(
      children: [
        Container(
          height: 160,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          alignment: Alignment.center,
          child: _productImage(),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: widget.onRemove,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _productImage() {
    final url = widget.product.imageUrl?.trim() ?? '';
    if (url.startsWith('http')) {
      return Image.network(
        url,
        height: 120,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _placeholderImage(),
      );
    }
    return _placeholderImage();
  }

  Widget _placeholderImage() {
    return Container(
      width: 90,
      height: 90,
      decoration: const BoxDecoration(
        color: _tealLight,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.diamond_outlined, size: 38, color: _teal),
    );
  }

  // ── Info section ─────────────────────────────────────────────────────────

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price
          Text(
            _displayPrice,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF1A1A1A),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1, height: 1),
          const SizedBox(height: 6),
          // UID row
          _labelValueRow('UID:', _uid),
          const SizedBox(height: 3),

          // Product ID row
          _labelValueRow('Product ID:', widget.product.id.toString()),
          const SizedBox(height: 8),

          // View Details toggle
          _viewDetailsToggle(),

          // Collapsible detail rows
          if (_expanded) ...[const SizedBox(height: 8), _detailsSection()],

          const SizedBox(height: 10),

          // ── Add To Cart button ───────────────────────────────────────────
          if (widget.onAddToCart != null)
            SizedBox(
              width: double.infinity,
              height: 36,
              child: OutlinedButton(
                onPressed: widget.onAddToCart,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _teal,
                  side: const BorderSide(color: _teal, width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Add To Cart',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget _labelValueRow(String label, String value) {
  //   return RichText(
  //     text: TextSpan(
  //       style: const TextStyle(fontSize: 11.5, height: 1.4),
  //       children: [
  //         TextSpan(
  //           text: label,
  //           style: const TextStyle(
  //             fontWeight: FontWeight.w600,
  //             color: Color(0xFF6C5022),
  //           ),
  //         ),
  //         const TextSpan(text: '  '),
  //         TextSpan(
  //           text: value,
  //           style: const TextStyle(color: _valueColor),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _labelValueRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6C5022),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.4,
              color: _valueColor,
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget _viewDetailsToggle() {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'View Details',
            style: TextStyle(
              color: Color(0xFF6C5022),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
              decorationColor: _teal.withOpacity(0.4),
            ),
          ),
          const SizedBox(width: 3),
          AnimatedRotation(
            turns: _expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF6C5022),
              size: 17,
            ),
          ),
        ],
      ),
    );
  }

  // ── Collapsible details ──────────────────────────────────────────────────

  Widget _detailsSection() {
    final rows = <_DetailRow>[
      if (_solitaireLine != null)
        _DetailRow(label: 'Divine Solitaire:', value: _solitaireLine!),
      if (_mountLine != null)
        _DetailRow(label: 'Divine Mount:', value: _mountLine!),
      if (_sideDiamondsLine != null)
        _DetailRow(label: 'Side Diamonds:', value: _sideDiamondsLine!),
      if (_sizeLine != null) _DetailRow(label: 'Size:', value: _sizeLine!),
    ];

    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 4),
        child: Text(
          'No additional details available.',
          style: TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      // decoration: const BoxDecoration(
      //   border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows
            .map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _labelValueRow(r.label, r.value),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal helpers
// ─────────────────────────────────────────────────────────────────────────────

class _DetailRow {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});
}
