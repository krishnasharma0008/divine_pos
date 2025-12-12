import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductCard extends StatelessWidget {
  final String image;
  final String title;
  final String price;
  final String tagText;
  final Color tagColor;
  final bool isSoldOut;
  final bool isWide;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTryOn;

  const ProductCard({
    super.key,
    required this.image,
    required this.title,
    required this.price,
    this.tagText = "",
    this.tagColor = Colors.transparent,
    this.isSoldOut = false,
    this.isWide = false,
    this.onAddToCart,
    this.onTryOn,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        isWide ? _buildWide(context) : _buildNormal(context),

        // ---------------------------------------------------
        // FULL CARD SOLD-OUT OVERLAY
        // ---------------------------------------------------
        if (isSoldOut)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.80),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: const Text(
                    "Sold out",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ---------------------------
  // NORMAL CARD
  // ---------------------------
  Widget _buildNormal(BuildContext context) {
    return Container(
      //width: 200,
      //decoration: BoxDecoration(
      //color: Colors.white,
      //borderRadius: BorderRadius.circular(14),
      //border: Border.all(color: Colors.grey.shade300),
      //),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _imageStack(),
          const SizedBox(height: 10),
          _title(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _price()),

                // keep spacing when sold out
                isSoldOut
                    ? const SizedBox(width: 100, height: 46)
                    : SizedBox(
                        width: 100,
                        child: _actionsRow(
                          mainAxisAlignment: MainAxisAlignment.end,
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ---------------------------
  // WIDE CARD
  // ---------------------------
  Widget _buildWide(BuildContext context) {
    return Container(
      //decoration: BoxDecoration(
      //color: Colors.white,
      //borderRadius: BorderRadius.circular(14),
      // boxShadow: [
      //   BoxShadow(
      //     color: Colors.black.withOpacity(0.05),
      //     blurRadius: 10,
      //     offset: const Offset(0, 4),
      //   ),
      // ],
      //),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _imageStack(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _title(),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _price()),

                // keep spacing when sold out
                isSoldOut
                    ? const SizedBox(height: 46)
                    : SizedBox(
                        //width: 100,
                        child: _actionsRow(
                          mainAxisAlignment: MainAxisAlignment.end,
                        ),
                      ),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: _price(),
          // ),
          // const SizedBox(height: 10),

          // keep height when sold out
          // isSoldOut
          //     ? const SizedBox(height: 46)
          //     : Container(
          //         padding: const EdgeInsets.symmetric(
          //           horizontal: 16,
          //           vertical: 10,
          //         ),
          //         decoration: const BoxDecoration(
          //           color: Color(0xFFF5FBFA),
          //           borderRadius: BorderRadius.vertical(
          //             bottom: Radius.circular(14),
          //           ),
          //         ),
          //         child: _actionsRow(mainAxisAlignment: MainAxisAlignment.end),
          //       ),
        ],
      ),
    );
  }

  // ---------------------------
  // IMAGE STACK
  // ---------------------------
  Widget _imageStack() {
    return Stack(
      children: [
        // MAIN IMAGE
        Container(
          height: 287,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xffF7F7F7),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.contain,
            ),
          ),
        ),

        // TAG
        if (tagText.isNotEmpty)
          Positioned(
            left: 14,
            top: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tagColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tagText,
                style: TextStyle(
                  fontSize: 12,
                  color: tagColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        // WISHLIST ICON
        Positioned(
          right: 14,
          top: 14,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border,
              color: Colors.teal,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _title() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 9),
    child: SizedBox(
      height: 36,
      child: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    ),
  );

  Widget _price() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 9),
    child: Text(
      price,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
  );

  Widget _actionsRow({required MainAxisAlignment mainAxisAlignment}) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        InkWell(
          onTap: onAddToCart,
          child: SvgPicture.asset(
            'assets/icons/cart.svg',
            width: 38,
            height: 40,
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onTryOn,
          child: SvgPicture.asset(
            'assets/icons/tryon.svg',
            width: 38,
            height: 40,
          ),
        ),
      ],
    );
  }
}
