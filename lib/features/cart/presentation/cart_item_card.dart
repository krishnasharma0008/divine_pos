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

  @override
  void initState() {
    super.initState();
    _engravingController = TextEditingController(
      text: widget.item.cartRemarks ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant CartItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.cartRemarks != widget.item.cartRemarks) {
      _engravingController.text = widget.item.cartRemarks ?? '';
    }
  }

  @override
  void dispose() {
    _engravingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final cartState = ref.watch(cartNotifierProvider);
    final notifier = ref.read(cartNotifierProvider.notifier);

    // Get latest version of this item from cart state
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

    // Engraving derived from remarks
    final isEngravingEnabled = (currentItem.cartRemarks ?? '')
        .trim()
        .isNotEmpty;

    // Keep controller in sync with current item
    final engravingText = currentItem.cartRemarks ?? '';
    if (_engravingController.text != engravingText) {
      _engravingController.value = TextEditingValue(
        text: engravingText,
        selection: TextSelection.fromPosition(
          TextPosition(offset: engravingText.length),
        ),
      );
    }

    final fem = ScaleSize.aspectRatio;

    return Container(
      margin: EdgeInsets.fromLTRB(24 * fem, 0 * fem, 24 * fem, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(widget.isTopRounded ? 18 * fem : 0),
          bottom: Radius.circular(widget.isBottomRounded ? 18 * fem : 0),
        ),
      ),

      child: Stack(
        children: [
          // main content with padding
          Padding(
            padding: EdgeInsets.fromLTRB(24 * fem, 24 * fem, 24 * fem, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TOP ROW: image + details(with qty) + price
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // vertical center
                  children: [
                    _Image(currentItem.imageUrl),

                    SizedBox(width: 24 * fem),

                    // left: title + details + qty
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Details(
                            item: currentItem,
                            notifier: notifier,
                            fem: fem,
                          ),
                          SizedBox(height: 15 * fem),

                          /// ENGRAVING CHECKBOX
                          Row(
                            children: [
                              Checkbox(
                                value: isEngravingEnabled,
                                onChanged: (value) {
                                  notifier.toggleEngraving(
                                    currentItem.id ?? 0,
                                    value ?? false,
                                  );
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4 * fem),
                                ),
                                side: BorderSide(
                                  width: 0.88,
                                  color: Colors.black.withValues(alpha: 0.10),
                                ),
                                activeColor:
                                    Colors.black, // background when checked
                                checkColor: Colors.white,
                              ),
                              MyText(
                                'Add Engraving',
                                style: TextStyle(
                                  color: const Color(0xFF0A0A0A),
                                  fontSize: 14 * fem,
                                  fontFamily: 'Montserrat',
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
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w400,
                                  height: 1.43,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14 * fem),

                          /// ENGRAVING TEXT AREA
                          if (isEngravingEnabled)
                            Container(
                              margin: EdgeInsets.only(top: 8 * fem),
                              padding: EdgeInsets.all(16 * fem),
                              decoration: BoxDecoration(
                                color: const Color(0x19BEE4DD),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0x4CBEE4DD),
                                  width: 1,
                                ),
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
                                    key: ValueKey(
                                      'engraving_${currentItem.id}',
                                    ),
                                    maxLength: 100,
                                    controller: _engravingController,
                                    onChanged: (val) {
                                      notifier.updateEngravingText(
                                        currentItem.id ?? 0,
                                        val,
                                      );
                                    },
                                    decoration: const InputDecoration(
                                      hintText:
                                          'Enter your engraving text (max 10 words)',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        borderSide: BorderSide(
                                          color: Color(0xFFE2ECE9),
                                          width: 1,
                                        ),
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
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 14 * fem),
                        ],
                      ),
                    ),

                    //SizedBox(width: 48 * fem),

                    // right: price block, vertically centered
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [_Price(currentItem, fem)],
                    ),
                  ],
                ),

                //SizedBox(height: 18 * fem),
              ],
            ),
          ),
          // X absolutely at top-right of card
          Positioned(
            top: 24 * fem,
            right: 43 * fem,
            child: IconButton(
              icon: const Icon(Icons.close),
              iconSize: 20 * fem,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: Color(0xFF99A1AF),
              onPressed: widget.onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

/// IMAGE
class _Image extends StatelessWidget {
  final String? url;

  const _Image(this.url);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 180,
        height: 180,
        child: url != null && url!.isNotEmpty
            ? Image.network(url!, fit: BoxFit.cover)
            : Image.asset('assets/no_image.jpg'),
      ),
    );
  }
}

/// DETAILS + QTY
class _Details extends StatelessWidget {
  final CartDetail item;
  final CartNotifier notifier;
  final double fem;

  const _Details({
    required this.item,
    required this.notifier,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) {
    //final isEngravingEnabled = (item.cartRemarks ?? '').trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          'Rings- ${item.productCode ?? ''}',
          style: TextStyle(
            color: const Color(0xFF0A0A0A),
            fontSize: 18 * fem,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            height: 1.56,
          ),
        ),
        SizedBox(height: 6),
        MyText(
          'Divine Solitaire Round ${item.solitaireSlab ?? ''} '
          '${item.solitaireColor ?? ''} ${item.solitaireQuality ?? ''} '
          '(${item.solitairePcs ?? 0} Pcs)',
          style: TextStyle(
            color: const Color(0xFF354152),
            fontSize: 14 * fem,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.43,
          ),
        ),
        MyText(
          'Divine Mount:  Metal- ${item.metalPurity ?? ''} '
          '${item.metalColor ?? ''} ${item.metalWeight ?? 0}gms',
          style: TextStyle(
            color: const Color(0xFF354152),
            fontSize: 14 * fem,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.43,
          ),
        ),
        MyText(
          'Side Diamonds Qty ${item.sideStonePcs ?? 0} / '
          '${item.sideStoneCts ?? 0}ct. ${item.sideStoneColor ?? ''} ${item.sideStoneQuality ?? ''}',
          style: TextStyle(
            color: const Color(0xFF354152),
            fontSize: 14 * fem,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.43,
          ),
        ),
        MyText(
          'Size: ${item.sizeFrom ?? ''}',
          style: TextStyle(
            color: const Color(0xFF354152),
            fontSize: 14 * fem,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.43,
          ),
        ),
        SizedBox(height: 14 * fem),
        _QtyControl(
          value: item.productQty ?? 1,
          onMinus: () => notifier.updateQuantity(item.id ?? 0, false),
          onPlus: () => notifier.updateQuantity(item.id ?? 0, true),
          fem: fem,
        ),
      ],
    );
  }
}

/// PRICE
class _Price extends StatelessWidget {
  final CartDetail item;
  final double fem;

  const _Price(this.item, this.fem);

  @override
  Widget build(BuildContext context) {
    final min = item.productAmtMin ?? 0;
    final max = item.productAmtMax ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        MyText(
          '${min.inRupeesFormat()} - ${max.inRupeesFormat()}',
          style: TextStyle(
            color: const Color(0xFF0A0A0A),
            fontSize: 24 * fem,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            height: 1.33,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

/// QTY BUTTON
class _QtyControl extends StatelessWidget {
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final double fem;

  const _QtyControl({
    required this.value,
    required this.onMinus,
    required this.onPlus,
    required this.fem,
  });

  @override
  Widget build(BuildContext context) {
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
          // minus box
          SizedBox(
            width: 39.98 * fem,
            height: 39.98 * fem,
            child: InkWell(
              onTap: onMinus,
              child: Center(
                child: Icon(
                  Icons.remove,
                  size: 16 * fem,
                  color: Color(0xFF0A0A0A),
                ),
              ),
            ),
          ),

          // number
          Expanded(
            child: Center(
              child: Text(
                '$value',
                style: TextStyle(
                  color: Color(0xFF0A0A0A),
                  fontSize: 16 * fem,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
          ),

          // plus box
          SizedBox(
            width: 39.98 * fem,
            height: 39.98 * fem,
            child: InkWell(
              onTap: onPlus,
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 16 * fem,
                  color: Color(0xFF0A0A0A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
