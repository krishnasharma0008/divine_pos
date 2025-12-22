import 'package:flutter/material.dart';
import '../../../shared/widgets/text.dart';
import '../../../shared/utils/scale_size.dart';
import '../../../shared/widgets/text.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ar = ScaleSize.aspectRatio.clamp(0.7, 1.3);
    final tiles = [
      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: 'assets/dashboard/categories/cat_rings.png',
        label: 'Rings',
        productWidth: 132,
        productHeight: 125,
      ),
      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: 'assets/dashboard/categories/cat_earrings.png',
        label: 'Earrings',
        productWidth: 160,
        productHeight: 90,
      ),
      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: 'assets/dashboard/categories/cat_necklaces.png',
        label: 'Necklaces',
        productWidth: 210,
        productHeight: 210,
      ),
      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: 'assets/dashboard/categories/cat_pendants.png',
        label: 'Pendants',
        productWidth: 134,
        productHeight: 205,
      ),
      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: 'assets/dashboard/categories/cat_bangles.png',
        label: 'Bangles',
        productWidth: 169,
        productHeight: 169,
      ),

      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: 'assets/dashboard/categories/cat_solitaire.png',
        label: 'Solitaire',
        productWidth: 111,
        productHeight: 99,
      ),
      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: 'assets/dashboard/categories/cat_bracelet.png',
        label: 'Bracelet',
        productWidth: 120,
        productHeight: 120,
      ),
      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: 'assets/dashboard/categories/cat_mangalsutra.png',
        label: 'Mangalsutra',
        productWidth: 210,
        productHeight: 165,
      ),

      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: 'assets/dashboard/categories/cat_maleaerring.png',
        label: 'Male Earring',
        productWidth: 148,
        productHeight: 94,
      ),
      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: '',
        label: '',
        productWidth: 143,
        productHeight: 24,
        isCta: true,
      ),
    ];

    final firstRow = tiles.take(5).toList();
    final secondRow = tiles.skip(5).take(5).toList();

    return Center(
      // ✅ force center on screen
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * ar),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, // ✅ horizontal center
          children: [
            /// TITLE
            MyText(
              'CATEGORIES',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20 * ar,
                fontFamily: 'Rushter Glory',
                fontWeight: FontWeight.w400,
                height: 1.1,
                letterSpacing: 0.4,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 6 * ar),

            /// SUBTITLE
            MyText(
              'Beautifully Organized. Brilliantly Designed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15 * ar,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                height: 1.47,
                letterSpacing: 0.3,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 92 * ar),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(firstRow.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: i == firstRow.length - 1 ? 0 : 24 * ar,
                  ),
                  child: firstRow[i],
                );
              }),
            ),

            SizedBox(height: 32 * ar),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(secondRow.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: i == secondRow.length - 1 ? 0 : 24 * ar,
                  ),
                  child: secondRow[i],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String backgroundAsset;
  final String productAsset;
  final String label;
  final bool isCta;

  final double productWidth;
  final double productHeight;

  const CategoryTile({
    super.key,
    required this.backgroundAsset,
    required this.productAsset,
    required this.label,
    required this.productWidth,
    required this.productHeight,
    this.isCta = false,
  });

  @override
  Widget build(BuildContext context) {
    final ar = ScaleSize.aspectRatio.clamp(0.7, 1.3);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// IMAGE TILE
        SizedBox(
          width: 210 * ar,
          height: 210 * ar,
          child: Stack(
            children: [
              /// BACKGROUND IMAGE
              Positioned.fill(
                child: Image.asset(backgroundAsset, fit: BoxFit.cover),
              ),

              /// FOREGROUND PRODUCT IMAGE
              if (isCta)
                Center(
                  child: MyText(
                    'All Categories',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20 * ar,
                      fontWeight: FontWeight.w400,
                      height: 1.1,
                      letterSpacing: 0.4,
                      color: Colors.white,
                      //Text-Transform: TextTransform.capitalize,
                    ),
                  ),
                )
              else
                Center(
                  child: SizedBox(
                    width: productWidth * ar,
                    height: productHeight * ar,
                    child: Image.asset(productAsset, fit: BoxFit.contain),
                  ),
                ),
              // Positioned(
              //   left: 39 * ar,
              //   top: 41 * ar,
              //   child: Container(
              //     width: 132 * ar,
              //     height: 132 * ar,
              //     decoration: BoxDecoration(
              //       image: DecorationImage(
              //         image: AssetImage(productAsset),
              //         fit: BoxFit.contain,
              //       ),
              //       boxShadow: const [
              //         BoxShadow(
              //           color: Color(0x3F000000),
              //           blurRadius: 4,
              //           offset: Offset(0, 4),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),

        SizedBox(height: 10 * ar),

        /// LABEL (outside image)
        if (!isCta)
          Text(
            label,
            style: TextStyle(
              fontSize: 14 * ar,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6A6A6A),
            ),
          ),
      ],
    );
  }
}
