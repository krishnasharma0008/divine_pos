import 'package:divine_pos/shared/utils/currency_formatter.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/scale_size.dart';
import '../data/cart_detail_model.dart';
import '../providers/cart_providers.dart';

class CartItemCard extends ConsumerStatefulWidget {
  final CartDetail item;
  final VoidCallback? onDelete;
  final bool isTopRounded;
  final bool isBottomRounded;
  final bool compact;

  const CartItemCard({
    super.key,
    required this.item,
    this.onDelete,
    this.isTopRounded = false,
    this.isBottomRounded = false,
    this.compact = false,
  });

  @override
  ConsumerState<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends ConsumerState<CartItemCard> {
  late final TextEditingController _engravingController;
  bool _engravingEnabled = false;

  @override
  void initState() {
    super.initState();
    _engravingEnabled = (widget.item.engraving ?? '').trim().isNotEmpty;
    _engravingController = TextEditingController(
      text: widget.item.engraving ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant CartItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.engraving != widget.item.engraving) {
      _engravingController.text = widget.item.engraving ?? '';
    }
  }

  @override
  void dispose() {
    _engravingController.dispose();
    super.dispose();
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildImage(String? url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 180,
        height: 180,
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                        color: const Color(0xFFF5F5F5),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/jewellery/No_Image_Available.jpg',
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                'assets/jewellery/No_Image_Available.jpg',
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _buildDetails(CartDetail item, CartNotifier notifier, double fem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          '${item.productSubCategory ?? ''} - ${item.productCode ?? ''}',
          style: TextStyle(
            color: const Color(0xFF0A0A0A),
            fontSize: 18 * fem,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            height: 1.56,
          ),
        ),
        const SizedBox(height: 6),
        ...[
          'Divine Solitaire Round ${item.solitaireSlab ?? ''} '
              '${item.solitaireColor ?? ''} ${item.solitaireQuality ?? ''} '
              '(${item.solitairePcs ?? 0} Pcs)',
          'Divine Mount:  Metal- ${item.metalPurity ?? ''} '
              '${item.metalColor ?? ''} ${item.metalWeight ?? 0}gms',
          'Side Diamonds Qty ${item.sideStonePcs ?? 0} / '
              '${item.sideStoneCts ?? 0}ct. ${item.sideStoneColor ?? ''} ${item.sideStoneQuality ?? ''}',
          'Size: ${item.sizeFrom ?? ''}',
        ].map(
          (text) => MyText(
            text,
            style: TextStyle(
              color: const Color(0xFF354152),
              fontSize: 14 * fem,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.43,
            ),
          ),
        ),
        SizedBox(height: 14 * fem),
        _buildQtyControl(item, notifier, fem),
      ],
    );
  }

  Widget _buildQtyControl(CartDetail item, CartNotifier notifier, double fem) {
    return Container(
      width: 136.16 * fem,
      height: 41.74 * fem,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.88, color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        children: [
          _qtyButton(
            Icons.remove,
            fem,
            () => notifier.updateQuantity(item.id ?? 0, false),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${item.productQty ?? 1}',
                style: TextStyle(
                  color: const Color(0xFF0A0A0A),
                  fontSize: 16 * fem,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
          ),
          _qtyButton(
            Icons.add,
            fem,
            () => notifier.updateQuantity(item.id ?? 0, true),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, double fem, VoidCallback onTap) {
    return SizedBox(
      width: 39.98 * fem,
      height: 39.98 * fem,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Icon(icon, size: 16 * fem, color: const Color(0xFF0A0A0A)),
        ),
      ),
    );
  }

  Widget _buildPrice(CartDetail item, double fem) {
    final min = item.productAmtMin ?? 0;
    final max = item.productAmtMax ?? 0;
    return MyText(
      '${min.inRupeesFormat()} - ${max.inRupeesFormat()}',
      style: TextStyle(
        color: const Color(0xFF0A0A0A),
        fontSize: 24 * fem,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
        height: 1.33,
      ),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildEngravingSection(
    CartDetail item,
    CartNotifier notifier,
    double fem,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _engravingEnabled,
              onChanged: (value) {
                setState(() => _engravingEnabled = value ?? false);
                notifier.toggleEngraving(item.id ?? 0, value ?? false);
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4 * fem),
              ),
              side: BorderSide(
                width: 0.88,
                color: Colors.black.withValues(alpha: 0.10),
              ),
              activeColor: Colors.black,
              checkColor: Colors.white,
            ),
            MyText(
              'Add Engraving',
              style: TextStyle(
                color: const Color(0xFF0A0A0A),
                fontSize: 14 * fem,
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),
            SizedBox(width: 4 * fem),
            MyText(
              '(+ ₹ 1,000)',
              style: TextStyle(
                color: const Color(0xFF697282),
                fontSize: 14 * fem,
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),
          ],
        ),
        if (_engravingEnabled) ...[
          SizedBox(height: 8 * fem),
          Container(
            padding: EdgeInsets.all(16 * fem),
            decoration: BoxDecoration(
              color: const Color(0x19BEE4DD),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x4CBEE4DD)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  'Engraving Text',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14 * fem,
                  ),
                ),
                SizedBox(height: 10 * fem),
                TextField(
                  key: ValueKey('engraving_${item.id}'),
                  maxLength: 100,
                  controller: _engravingController,
                  onChanged: (val) =>
                      notifier.updateEngravingText(item.id ?? 0, val),
                  decoration: const InputDecoration(
                    hintText: 'Enter your engraving text (max 10 words)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Color(0xFFE2ECE9)),
                    ),
                    counterText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Maximum 10 words',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: 14 * fem),
      ],
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(cartNotifierProvider.notifier);
    final fem = ScaleSize.aspectRatio;

    final currentItem = ref.watch(
      cartNotifierProvider.select(
        (state) => state.when(
          data: (list) => list.firstWhere(
            (e) => e.id == widget.item.id,
            orElse: () => widget.item,
          ),
          loading: () => widget.item,
          error: (_, __) => widget.item,
        ),
      ),
    );

    return Container(
      margin: EdgeInsets.fromLTRB(24 * fem, 0, 24 * fem, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(widget.isTopRounded ? 18 * fem : 0),
          bottom: Radius.circular(widget.isBottomRounded ? 18 * fem : 0),
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24 * fem, 24 * fem, 24 * fem, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildImage(currentItem.imageUrl),
                SizedBox(width: 24 * fem),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetails(currentItem, notifier, fem),
                      _buildEngravingSection(currentItem, notifier, fem),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_buildPrice(currentItem, fem)],
                ),
              ],
            ),
          ),
          Positioned(
            top: 24 * fem,
            right: 43 * fem,
            child: IconButton(
              icon: const Icon(Icons.close),
              iconSize: 20 * fem,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: const Color(0xFF99A1AF),
              onPressed: widget.onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
