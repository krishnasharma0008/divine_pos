import 'package:divine_pos/shared/utils/currency_formatter.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/utils/scale_size.dart';
import '../data/cart_detail_model.dart';
import '../providers/cart_providers.dart';

class DiamondShape {
  final String value;
  final String assetPath;

  const DiamondShape({required this.value, required this.assetPath});
}

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

  static const allShapes = <DiamondShape>[
    DiamondShape(value: 'Round', assetPath: 'assets/diamond_value/round.png'),
    DiamondShape(
      value: 'Princess',
      assetPath: 'assets/diamond_value/princess.png',
    ),
    DiamondShape(value: 'Pear', assetPath: 'assets/diamond_value/pear.png'),
    DiamondShape(value: 'Oval', assetPath: 'assets/diamond_value/oval.png'),
    DiamondShape(
      value: 'Radiant',
      assetPath: 'assets/diamond_value/radiant.png',
    ),
    DiamondShape(
      value: 'Cushion',
      assetPath: 'assets/diamond_value/cushion.png',
    ),
    DiamondShape(value: 'Heart', assetPath: 'assets/diamond_value/heart.png'),
  ];

  // String? getShapeAsset(String? shape) {
  //   if (shape == null) return null;

  //   final match = allShapes.firstWhere(
  //     (s) => s.value.toLowerCase() == shape.toLowerCase(),
  //     orElse: () => const DiamondShape(value: '', assetPath: ''),
  //   );

  //   return match.assetPath.isEmpty ? null : match.assetPath;
  // }

  String? getShapeAsset(String? shape) {
    if (shape == null) return null;

    final normalized = switch (shape.trim().toUpperCase()) {
      'RND' => 'Round',
      'PRN' => 'Princess',
      'PER' => 'Pear',
      'OVL' => 'Oval',
      'RADQ' => 'Radiant',
      'CUSQ' => 'Cushion',
      'HRT' => 'Heart',
      _ => shape.trim(), // whatever string comes from API, e.g. "Round"
    };

    final match = allShapes.firstWhere(
      (s) => s.value.toLowerCase() == normalized.toLowerCase(),
      orElse: () => const DiamondShape(value: '', assetPath: ''),
    );

    return match.assetPath.isEmpty ? null : match.assetPath;
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildImage(String? url) {
    final isNetwork = url != null && url.startsWith('http');

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 180,
        height: 180,
        child: isNetwork
            ? Image.network(
                url!,
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
                (url != null && url.isNotEmpty)
                    ? url
                    : 'assets/jewellery/No_Image_Available.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/jewellery/No_Image_Available.jpg',
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  Widget _buildDetails(CartDetail item, CartNotifier notifier, double fem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //if (item.productType != 'solitaire') ...[
        MyText(
          '${item.productSubCategory ?? ''} ${item.productSubCategory ?? ' - '} ${item.productCode ?? ''}',
          style: TextStyle(
            color: const Color(0xFF0A0A0A),
            fontSize: 18 * fem,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            height: 1.56,
          ),
        ),
        //],
        const SizedBox(height: 6),
        ...[
          'Divine Solitaire ${item.solitaireShape ?? ''}  ${(item.solitaireSlab ?? '')} '
              '${item.solitaireColor ?? ''} ${item.solitaireQuality ?? ''} '
              '(${item.solitairePcs ?? 0} Pcs)',
          if ((item.productType ?? '').toLowerCase() != 'solitaire')
            {
              'Divine Mount:  Metal- ${item.metalPurity ?? ''} '
                  '${item.metalColor ?? ''} ${item.metalWeight ?? 0}gms',
              'Side Diamonds Qty ${item.sideStonePcs ?? 0} / '
                  '${(item.sideStoneCts ?? 0).toStringAsFixed(2)}ct. ${item.sideStoneColor ?? ''} ${item.sideStoneQuality ?? ''}',
              'Size: ${item.sizeFrom ?? ''}',
            },
          'Expected Delivery Date: ${item.expDlvDate != null && item.expDlvDate!.isNotEmpty ? DateFormat('dd-MM-yyyy').format(DateTime.parse(item.expDlvDate!)) : 'N/A'}',
        ].map(
          (text) => MyText(
            text.toString(),
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
        //_buildQtyControl(item, notifier, fem),
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

  // ── Price: hidden when both min and max are 0 ────────────────────────────────
  Widget? _buildPrice(CartDetail item, double fem) {
    final min = item.productAmtMin ?? 0;
    final max = item.productAmtMax ?? 0;

    if (min == 0 && max == 0) return null;

    return MyText(
      '${min == 0 ? '' : min.inRupeesFormat()} ${min == 0 ? '' : '-'} ${max == 0 ? '' : max.inRupeesFormat()}',
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

    final priceWidget = _buildPrice(currentItem, fem);

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
                (currentItem.productType ?? '').toLowerCase() == "jewellery"
                    ? _buildImage(currentItem.imageUrl)
                    : _buildImage(getShapeAsset(currentItem.solitaireShape)),

                //_buildImage(currentItem.imageUrl),
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
                if (priceWidget != null)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [priceWidget],
                  ),
              ],
            ),
          ),

          // ── Circular close button — top-right of card ──────────────────────
          Positioned(
            top: 12 * fem,
            right: 12 * fem,
            child: GestureDetector(
              onTap: widget.onDelete,
              child: Container(
                width: 28 * fem,
                height: 28 * fem,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                ),
                child: Center(
                  child: Icon(
                    Icons.close,
                    size: 14 * fem,
                    color: const Color(0xFF99A1AF),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
