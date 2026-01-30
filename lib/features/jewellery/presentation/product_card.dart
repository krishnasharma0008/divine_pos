import 'package:divine_pos/shared/utils/currency_formatter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../shared/utils/scale_size.dart';
import '../../../shared/widgets/text.dart';

class ProductCard extends StatefulWidget {
  final String image;
  final String description;
  final double? price;
  final String tagText;
  final Color tagColor;
  final bool isSoldOut;
  final bool isWide;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTryOn;
  final VoidCallback? onHaertTap;

  const ProductCard({
    super.key,
    required this.image,
    required this.description,
    required this.price,
    this.tagText = "",
    this.tagColor = Colors.transparent,
    this.isSoldOut = false,
    this.isWide = false,
    this.onAddToCart,
    this.onTryOn,
    this.onHaertTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  bool get _enableHover =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  @override
  Widget build(BuildContext context) {
    final r = ScaleSize.aspectRatio;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      transform: _isHovered
          ? (Matrix4.identity()..translate(0.0, -6.0))
          : Matrix4.identity(),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: _isHovered
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Stack(
        children: [
          widget.isWide ? _buildWide(context, r) : _buildNormal(context, r),
          if (widget.isSoldOut) _soldOutOverlay(r),
        ],
      ),
    );

    if (!_enableHover) return card;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: card,
    );
  }

  // ---------------- NORMAL CARD ----------------

  Widget _buildNormal(BuildContext context, double r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _imageStack(r),
        SizedBox(height: 8 * r),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _price(r)),
            if (!widget.isSoldOut)
              _actionsRow(mainAxisAlignment: MainAxisAlignment.end, r: r),
          ],
        ),
        SizedBox(height: 8 * r),
      ],
    );
  }

  // ---------------- WIDE CARD ----------------

  Widget _buildWide(BuildContext context, double r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _imageStack(r),
        // SizedBox(height: 10 * r),
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 16 * r),
        //   child: _description(r),
        // ),
        SizedBox(height: 8 * r),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _price(r)),
            if (!widget.isSoldOut)
              _actionsRow(mainAxisAlignment: MainAxisAlignment.end, r: r),
          ],
        ),
        SizedBox(height: 8 * r),
      ],
    );
  }

  // ---------------- IMAGE STACK ----------------

  Widget _imageStack(double r) {
    final bool isNetwork = widget.image.startsWith('http');

    return Stack(
      children: [
        SizedBox(
          height: 287 * r,
          width: double.infinity,
          //color: Colors.amber,
          child: Center(
            child: isNetwork
                ? Image.network(
                    widget.image,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return SizedBox(
                        width: 120 * r,
                        height: 120 * r,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (_, __, ___) => _noImageAsset(r),
                  )
                : Image.asset(
                    widget.image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _noImageAsset(r),
                  ),
          ),
        ),

        // TAG
        if (widget.tagText.isNotEmpty)
          Positioned(
            left: 14 * r,
            top: 14 * r,
            child: MyText(
              widget.tagText,
              style: TextStyle(
                fontSize: 13 * r,
                fontWeight: FontWeight.w300,
                color: widget.tagColor,
              ),
            ),
          ),

        // HEART
        Positioned(
          right: 14 * r,
          top: 14 * r,
          child: InkWell(
            onTap: widget.onHaertTap,
            child: SvgPicture.asset(
              'assets/icons/heart.svg',
              width: 35 * r,
              height: 36 * r,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- SOLD OUT ----------------

  Widget _soldOutOverlay(double r) {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withValues(alpha: 0.80),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20 * r, vertical: 8 * r),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: MyText(
              "Sold out",
              style: TextStyle(fontSize: 14 * r, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Widget _noImageAsset(double r) {
    return Image.asset(
      'assets/jewellery/No_Image_Available.jpg',
      fit: BoxFit.contain,
      width: 120 * r,
      opacity: const AlwaysStoppedAnimation(0.6),
    );
  }

  Widget _description(double r) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 9 * r),
    child: SizedBox(
      height: 36 * r,
      child: MyText(
        widget.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13 * r,
          fontWeight: FontWeight.w300,
          height: 1.54,
        ),
      ),
    ),
  );

  Widget _price(double r) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 9 * r),
    child: MyText(
      widget.price == null
          ? 'Price on request'
          : widget.price!.inRupeesFormat(),
      style: TextStyle(fontSize: 16 * r, fontWeight: FontWeight.w500),
    ),
  );

  Widget _actionsRow({
    required MainAxisAlignment mainAxisAlignment,
    required double r,
  }) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        InkWell(
          onTap: widget.onAddToCart,
          child: SvgPicture.asset(
            'assets/icons/cart.svg',
            width: 44 * r,
            height: 46 * r,
          ),
        ),
        SizedBox(width: 12 * r),
        InkWell(
          onTap: widget.onTryOn,
          child: SvgPicture.asset(
            'assets/icons/tryon.svg',
            width: 44 * r,
            height: 46 * r,
          ),
        ),
      ],
    );
  }
}
