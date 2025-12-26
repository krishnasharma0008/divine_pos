import 'package:divine_pos/shared/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../shared/utils/scale_size.dart';
import '../../../shared/widgets/text.dart';

class ProductCard extends StatelessWidget {
  final String image;
  final String description;
  final double price;
  final String tagText;
  final Color tagColor;
  final bool isSoldOut;
  final bool isWide;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTryOn;
  final VoidCallback? onHaertTap;
  //"Eternal Radiance Ring for Hera symbol of brilliance, balance."
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
  Widget build(BuildContext context) {
    final r = ScaleSize.aspectRatio;

    return Stack(
      children: [
        isWide ? _buildWide(context, r) : _buildNormal(context, r),
        if (isSoldOut)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.80),
                borderRadius: BorderRadius.circular(0),
              ),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20 * r,
                    vertical: 8 * r,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: MyText(
                    "Sold out",
                    style: TextStyle(
                      fontSize: 14 * r,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNormal(BuildContext context, double r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _imageStack(r),
        SizedBox(height: 10 * r),
        _description(r),
        SizedBox(height: 8 * r),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _price(r),
            if (!isSoldOut) SizedBox(height: 6 * r),
            if (!isSoldOut)
              _actionsRow(mainAxisAlignment: MainAxisAlignment.start, r: r),
          ],
        ),
        // child: Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Expanded(child: _price(r)),
        //     isSoldOut
        //         ? SizedBox(width: 100 * r, height: 46 * r)
        //         : SizedBox(
        //             width: 100 * r,
        //             child: _actionsRow(
        //               mainAxisAlignment: MainAxisAlignment.end,
        //               r: r,
        //             ),
        //           ),
        //   ],
        // ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildWide(BuildContext context, double r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _imageStack(r),
        SizedBox(height: 10 * r),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * r),
          child: _description(r),
        ),
        SizedBox(height: 8 * r),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _price(r),
            if (!isSoldOut) SizedBox(height: 6 * r),
            if (!isSoldOut)
              _actionsRow(mainAxisAlignment: MainAxisAlignment.start, r: r),
          ],
        ),
        // child: Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Expanded(child: _price(r)),
        //     isSoldOut
        //         ? SizedBox(height: 46 * r)
        //         : _actionsRow(mainAxisAlignment: MainAxisAlignment.end, r: r),
        //   ],
        // ),
      ],
    );
  }

  Widget _imageStack(double r) {
    // final ImageProvider provider = image.startsWith('http')
    //     ? NetworkImage(image)
    //     : AssetImage(image) as ImageProvider;
    final bool isNetwork = image.startsWith('http');
    return Stack(
      children: [
        Container(
          height: 287 * r,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xffF7F7F7),
            //borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            //image: DecorationImage(image: provider, fit: BoxFit.contain),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFCECECE).withValues(alpha: 0.25),
                blurRadius: 4,
                offset: Offset(2, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: isNetwork
                ? Image.network(
                    image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _noImageAsset(r),
                  )
                : Image.asset(
                    image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _noImageAsset(r),
                  ),
          ),
        ),

        if (tagText.isNotEmpty)
          Positioned(
            left: 14 * r,
            top: 14 * r,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10 * r,
                vertical: 4 * r,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                //borderRadius: BorderRadius.circular(20),
              ),
              child: MyText(
                tagText,
                style: TextStyle(
                  fontSize: 13 * r,
                  fontWeight: FontWeight.w300,
                  color: tagColor,
                ),
              ),
            ),
          ),
        Positioned(
          right: 14 * r,
          top: 14 * r,
          child: InkWell(
            onTap: onHaertTap,
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
        description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.black,
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
      price.inRupeesFormat(),
      style: TextStyle(
        color: const Color(0xFF212121),
        fontSize: 12 * r,
        fontWeight: FontWeight.w500,
      ),
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
          onTap: onAddToCart,
          child: SvgPicture.asset(
            'assets/icons/cart.svg',
            width: 44 * r,
            height: 46 * r,
          ),
        ),
        SizedBox(width: 12 * r),
        InkWell(
          onTap: onTryOn,
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
