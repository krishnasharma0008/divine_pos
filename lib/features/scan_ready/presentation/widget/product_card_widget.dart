import 'package:divine_pos/features/scan_ready/data/product_model.dart';
import 'package:flutter/material.dart';

/// A card that displays a single [product] in the scan-ready flow.
///
/// Cart state is intentionally NOT stored locally so it survives list rebuilds.
/// The caller must track [isInCart] and update it in response to [onCartToggle].
///
/// ```dart
/// ProductCard(
///   product: p,
///   isInCart: cartSet.contains(p.id),
///   onRemove: () => ...,
///   onCartToggle: (inCart) => setState(() {
///     inCart ? cartSet.add(p.id) : cartSet.remove(p.id);
///   }),
/// )
/// ```
class ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onRemove;

  /// Whether this product is currently in the cart.
  /// Must be managed by the parent so state survives list rebuilds.
  final bool isInCart;

  /// Called whenever the cart button is toggled.
  /// [inCart] is `true` when the user just added, `false` when removed.
  final ValueChanged<bool>? onCartToggle;

  const ProductCard({
    super.key,
    required this.product,
    required this.onRemove,
    this.isInCart = false,
    this.onCartToggle,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _expanded = false;

  static const Color _teal = Color(0xFF2BAFA0);
  static const Color _tealLight = Color(0xFFE0F5F2);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0EFEC), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
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

  Widget _buildImageSection() {
    return Stack(
      children: [
        Container(
          height: 150,
          decoration: const BoxDecoration(
            color: Color(0xFFF8FFFE),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          alignment: Alignment.center,
          child:
              (widget.product.imageUrl?.isNotEmpty ?? false) &&
                  (widget.product.imageUrl?.startsWith('http') ?? false)
              ? Image.network(
                  widget.product.imageUrl!,
                  height: 110,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _placeholderImage(),
                )
              : _placeholderImage(),
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
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 90,
      height: 90,
      decoration: const BoxDecoration(
        color: _tealLight,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.diamond_outlined, size: 40, color: _teal),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.mountAmtMax?.toString() ?? '-',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          _infoRow('UID:', widget.product.designno ?? '-'),
          const SizedBox(height: 2),
          _infoRow('Product ID:', widget.product.id.toString()),
          const SizedBox(height: 6),
          _viewDetailsToggle(),
          if (_expanded) ...[const SizedBox(height: 8), _detailsSection()],
          const SizedBox(height: 10),
          _addToCartButton(),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 11, color: Color(0xFF555555)),
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(text: '  '),
          TextSpan(
            text: value,
            style: const TextStyle(color: Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  Widget _viewDetailsToggle() {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'View Details',
            style: TextStyle(
              color: _teal,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          AnimatedRotation(
            turns: _expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(
              Icons.keyboard_arrow_down,
              color: _teal,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsSection() {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEF5F3), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.product
            .toJson()
            .entries
            .where((e) {
              final value = e.value;
              if (value == null) return false;
              // FIX: stringify before trimming so numbers aren't silently dropped
              if (value.toString().trim().isEmpty) return false;
              return true;
            })
            .map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 3),
                // FIX: e.value is dynamic; always convert to String explicitly
                child: _infoRow('${e.key}:', e.value?.toString() ?? '-'),
              );
            })
            .toList(),
      ),
    );
  }

  Widget _addToCartButton() {
    // FIX: use widget.isInCart (parent-owned) instead of local _inCart so the
    // button state survives list rebuilds (e.g. scrolling off-screen).
    final inCart = widget.isInCart;

    return GestureDetector(
      onTap: () {
        // FIX: fire onCartToggle for BOTH add and remove so the parent stays
        // in sync. Previously only fired on add.
        widget.onCartToggle?.call(!inCart);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: inCart ? _teal : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: inCart ? _teal : const Color(0xFFCCCCCC),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          inCart ? '✓  Added' : 'Add To Cart',
          style: TextStyle(
            color: inCart ? Colors.white : const Color(0xFF444444),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
