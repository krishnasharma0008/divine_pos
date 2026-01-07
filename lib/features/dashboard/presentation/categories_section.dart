import '../../../shared/routes/route_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/utils/enums.dart';
import '../../../shared/widgets/text.dart';
import '../../../shared/utils/scale_size.dart';

class CategoriesSection extends ConsumerWidget {
  const CategoriesSection({super.key});

  void ontap(BuildContext context, String paramValue) {
    if (paramValue.isEmpty) {
      GoRouter.of(
        context,
      ).pushReplacement(RoutePages.jewellerylisting.routePath);
    } else {
      GoRouter.of(context).pushReplacement(
        '${RoutePages.jewellerylisting.routePath}?${JewelleryProductKey.category.value}=${Uri.encodeComponent(paramValue)}',
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final notifier = ref.read(filterProvider.notifier);

    final ar = ScaleSize.aspectRatio.clamp(0.7, 1.3);
    final tiles = [
      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: 'assets/dashboard/categories/cat_rings.png',
        label: 'Rings',
        productWidth: 132,
        productHeight: 125,
        onTap: () {
          // notifier.resetFilters(); // optional
          // notifier.toggleCategory('Ring'); // ✅ set category

          // context.go(RoutePages.jewellerylisting.routePath);
          //GoRouter.of(context).pushReplacement(
          // context.push(
          //   '${RoutePages.jewellerylisting.routePath}?$paramKey=${Uri.encodeComponent('Ring')}',
          // );
          ontap(context, 'Ring');
        },
      ),
      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: 'assets/dashboard/categories/cat_earrings.png',
        label: 'Earrings',
        productWidth: 160,
        productHeight: 90,
        onTap: () {
          // notifier.resetFilters(); // optional
          // notifier.toggleCategory('Earrings'); // ✅ set category

          // context.go(RoutePages.jewellerylisting.routePath);
          // GoRouter.of(context).pushReplacement(
          //   //context.push(
          //   '${RoutePages.jewellerylisting.routePath}?${JewelleryProductKey.category.value}=${Uri.encodeComponent('Earring')}',
          // );
          ontap(context, 'Earring');
        },
      ),
      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: 'assets/dashboard/categories/cat_necklaces.png',
        label: 'Necklaces',
        productWidth: 210,
        productHeight: 210,
        onTap: () {
          // notifier.resetFilters(); // optional
          // notifier.toggleCategory('Necklaces'); // ✅ set category

          // context.go(RoutePages.jewellerylisting.routePath);
          // GoRouter.of(context).pushReplacement(
          //   //context.push(
          //   '${RoutePages.jewellerylisting.routePath}?${JewelleryProductKey.category.value}=${Uri.encodeComponent('Necklaces')}',
          // );
          ontap(context, 'Necklaces');
        },
      ),
      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: 'assets/dashboard/categories/cat_pendants.png',
        label: 'Pendants',
        productWidth: 134,
        productHeight: 205,
        onTap: () {
          // notifier.resetFilters(); // optional
          // notifier.toggleCategory('Pendants'); // ✅ set category

          // context.go(RoutePages.jewellerylisting.routePath);
          // GoRouter.of(context).pushReplacement(
          //   //context.push(
          //   '${RoutePages.jewellerylisting.routePath}?${JewelleryProductKey.category.value}=${Uri.encodeComponent('Pendants')}',
          // );
          ontap(context, 'Pendants');
        },
      ),
      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: 'assets/dashboard/categories/cat_bangles.png',
        label: 'Bangles',
        productWidth: 169,
        productHeight: 169,
        onTap: () {
          // notifier.resetFilters(); // optional
          // notifier.toggleCategory('Bangles'); // ✅ set category

          // context.go(RoutePages.jewellerylisting.routePath);
          // GoRouter.of(context).pushReplacement(
          //   //context.push(
          //   '${RoutePages.jewellerylisting.routePath}?${JewelleryProductKey.category.value}=${Uri.encodeComponent('Bangles')}',
          // );
          ontap(context, 'Bangles');
        },
      ),

      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: 'assets/dashboard/categories/cat_solitaire.png',
        label: 'Solitaire',
        productWidth: 111,
        productHeight: 99,
        onTap: () {
          // notifier.resetFilters(); // optional
          // notifier.toggleCategory('Solitaire'); // ✅ set category

          // context.go(RoutePages.jewellerylisting.routePath);
          // GoRouter.of(context).pushReplacement(
          //   //context.push(
          //   '${RoutePages.jewellerylisting.routePath}?${JewelleryProductKey.category.value}=${Uri.encodeComponent('Solitaire')}',
          // );
          ontap(context, 'Solitaire');
        },
      ),
      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: 'assets/dashboard/categories/cat_bracelet.png',
        label: 'Bracelet',
        productWidth: 120,
        productHeight: 120,
        onTap: () {
          // notifier.resetFilters(); // optional
          // notifier.toggleCategory('Bracelet'); // ✅ set category

          // context.go(RoutePages.jewellerylisting.routePath);
          // GoRouter.of(context).pushReplacement(
          //   //context.push(
          //   '${RoutePages.jewellerylisting.routePath}?${JewelleryProductKey.category.value}=${Uri.encodeComponent('Bracelet')}',
          // );
          ontap(context, 'Bracelet');
        },
      ),
      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: 'assets/dashboard/categories/cat_mangalsutra.png',
        label: 'Mangalsutra',
        productWidth: 210,
        productHeight: 165,
        onTap: () {
          // notifier.resetFilters(); // optional
          // notifier.toggleCategory('Mangalsutra'); // ✅ set category

          // context.go(RoutePages.jewellerylisting.routePath);
          // GoRouter.of(context).pushReplacement(
          //   //context.push(
          //   '${RoutePages.jewellerylisting.routePath}?${JewelleryProductKey.category.value}=${Uri.encodeComponent('Mangalsutra')}',
          // );
          ontap(context, 'Mangalsutra');
        },
      ),

      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: 'assets/dashboard/categories/cat_maleaerring.png',
        label: 'Male Earring',
        productWidth: 210,
        productHeight: 94,
        onTap: () {
          // notifier.resetFilters(); // optional
          // notifier.toggleCategory('Male Earring'); // ✅ set category

          // context.go(RoutePages.jewellerylisting.routePath);
          // GoRouter.of(context).pushReplacement(
          //   //context.push(
          //   '${RoutePages.jewellerylisting.routePath}?${JewelleryProductKey.category.value}=${Uri.encodeComponent('Male Earring')}',
          // );
          ontap(context, 'Male Earring');
        },
      ),
      CategoryTile(
        backgroundAsset: 'assets/dashboard/categories/bg_tile.png',
        productAsset: '',
        label: '',
        productWidth: 143,
        productHeight: 24,
        isCta: true,
        onTap: () {
          //notifier.resetFilters(); // optional

          //context.go(RoutePages.jewellerylisting.routePath);
          ontap(context, '');
        },
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

            SizedBox(
              //height: 260 * ar, // adjust as needed
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
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
  final VoidCallback? onTap; // ✅ ADD

  const CategoryTile({
    super.key,
    required this.backgroundAsset,
    required this.productAsset,
    required this.label,
    required this.productWidth,
    required this.productHeight,
    this.isCta = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ar = ScaleSize.aspectRatio.clamp(0.7, 1.3);

    return InkWell(
      onTap: onTap, // ✅
      borderRadius: BorderRadius.circular(12 * ar),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 210 * ar,
            height: 210 * ar,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(backgroundAsset, fit: BoxFit.cover),
                ),
                if (isCta)
                  Center(
                    child: Text(
                      'All Categories',
                      style: TextStyle(
                        fontSize: 20 * ar,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  )
                else
                  Center(
                    child: SizedBox(
                      width: productWidth * ar,
                      height: productHeight * ar,
                      child: Image.asset(productAsset),
                    ),
                  ),
              ],
            ),
          ),

          /// 👇 FIX: ALWAYS reserve space for label
          SizedBox(height: 10 * ar),

          MyText(
            isCta ? '' : label,
            style: TextStyle(
              fontSize: 14 * ar,
              color: isCta ? Colors.transparent : const Color(0xFF6A6A6A),
            ),
          ),
        ],
      ),
    );
  }
}
