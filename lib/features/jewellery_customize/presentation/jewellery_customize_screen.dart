import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import '../../../shared/utils/scale_size.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/app_bar.dart';
import '../../../shared/utils/enums.dart';

import 'top_header.dart';
import 'image_preview_with_thumbnails_old.dart'; //gallery
import "../data/product_images.dart";
//import 'customization_panel_old.dart'; //customization_panel
import 'button_bar.dart';
import 'tab_row.dart'; //tab panel

import 'solitaire_details_panel.dart';

import 'customize_solitaire.dart';

final dummyProductImages = [
  ProductImage(
    id: '1',
    url: 'assets/jewellery/filter_tags/rings.jpg',
    tagText: "Best Seller 🔥",
    tagColor: Colors.orange,
  ),
  ProductImage(
    id: '2',
    url: 'assets/jewellery/filter_tags/earrings.png',
    tagText: "New Arrival ✨",
    tagColor: Colors.teal,
  ),
  ProductImage(
    id: '3',
    url: 'assets/jewellery/filter_tags/bangles.jpg',
    tagText: "Trending 🔥",
    tagColor: Colors.green,
  ),
  ProductImage(
    id: '4',
    url: 'assets/jewellery/filter_tags/mangalsutra.jpg',
    tagText: "Best Seller 🔥",
    tagColor: Colors.orange,
  ),
];

class JewelleryCustomiseScreen extends StatefulWidget {
  const JewelleryCustomiseScreen({super.key});

  @override
  State<JewelleryCustomiseScreen> createState() =>
      _JewelleryCustomiseScreenState();
}

class _JewelleryCustomiseScreenState extends State<JewelleryCustomiseScreen> {
  int activeTab = 0;

  // Selected ranges
  // double? priceStart;
  // double? priceEnd;

  int? priceStartIndex;
  int? priceEndIndex;

  String? priceStartValue;
  String? priceEndValue;

  // double? caratStart;
  // double? caratEnd;
  int? caratStartIndex;
  int? caratEndIndex;

  String? caratStartValue;
  String? caratEndValue;

  int? colorStartIndex;
  int? colorEndIndex;
  String? colorStart;
  String? colorEnd;

  int? clarityStartIndex;
  int? clarityEndIndex;
  String? clarityStart;
  String? clarityEnd;

  String? ringSize;

  // Display strings
  String? priceRange;
  String? caratRange;
  String? colorRange;
  String? clarityRange;

  @override
  Widget build(BuildContext context) {
    final r = ScaleSize.aspectRatio;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: MyAppBar(
        appBarLeading: AppBarLeading.back,
        showLogo: false,
        actions: [
          //AppBarActionConfig(type: AppBarAction.search, onTap: () {}),
          //   AppBarActionConfig(
          //     type: AppBarAction.notification,
          //     badgeCount: 1,
          //     onTap: () => context.push('/notifications'),
          //   ),
          //   AppBarActionConfig(
          //     type: AppBarAction.profile,
          //     onTap: () => context.push('/profile'),
          //   ),
          AppBarActionConfig(
            type: AppBarAction.cart,
            badgeCount: 2,
            onTap: () => context.push('/cart'),
          ),
        ],
      ),
      //drawer: const SideDrawer(),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            /// SCROLLABLE MIDDLE
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * r),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// LEFT — 65%
                      Expanded(
                        flex: 6,
                        child: ImagePreviewWithThumbnails(
                          images: dummyProductImages,
                        ),
                      ),

                      SizedBox(width: 16 * r),

                      /// RIGHT — 35%
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 40 * r),
                            SizedBox(
                              width: 335 * r,
                              child: Text(
                                'Customize your Divine jewellery',
                                style: TextStyle(
                                  fontSize: 20 * r,
                                  fontFamily: 'Rushter Glory',
                                ),
                              ),
                            ),
                            SizedBox(height: 18 * r),
                            DeliveryBadge(r: r),
                            SizedBox(height: 23 * r),
                            DetailsScreen(
                              r: r,
                              priceRange: priceRange,
                              caratRange: caratRange,
                              colorRange: colorRange,
                              clarityRange: clarityRange,
                              ringSize: ringSize,
                            ),

                            Padding(
                              padding: EdgeInsets.only(right: 34 * r),
                              child: SizedBox(
                                width: 483 * r,
                                height: 41 * r,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20 * r),

                                    // ✅ THIS IS THE onTap
                                    onTap: () async {
                                      final result =
                                          await showDialog<
                                            Map<String, dynamic>
                                          >(
                                            context: context,
                                            barrierDismissible: true,
                                            builder: (_) => CustomizeSolitaire(
                                              initialValues: {
                                                if (priceStartIndex != null &&
                                                    priceEndIndex != null)
                                                  'price': {
                                                    'startIndex':
                                                        priceStartIndex,
                                                    'endIndex': priceEndIndex,
                                                  },

                                                // CARAT
                                                if (caratStartIndex != null &&
                                                    caratEndIndex != null)
                                                  'carat': {
                                                    'startIndex':
                                                        caratStartIndex,
                                                    'endIndex': caratEndIndex,
                                                  },

                                                // ✅ pass indices for color
                                                if (colorStartIndex != null &&
                                                    colorEndIndex != null)
                                                  'color': {
                                                    'startIndex':
                                                        colorStartIndex,
                                                    'endIndex': colorEndIndex,
                                                  },

                                                // ✅ pass indices for clarity
                                                if (clarityStartIndex != null &&
                                                    clarityEndIndex != null)
                                                  'clarity': {
                                                    'startIndex':
                                                        clarityStartIndex,
                                                    'endIndex': clarityEndIndex,
                                                  },
                                                if (ringSize != null)
                                                  'ringSize': ringSize,
                                              },
                                            ),
                                          );

                                      if (!mounted || result == null) return;

                                      setState(() {
                                        // PRICE
                                        priceStartIndex =
                                            result['price']?['startIndex'];
                                        priceEndIndex =
                                            result['price']?['endIndex'];

                                        priceStartValue =
                                            result['price']?['startValue'];
                                        priceEndValue =
                                            result['price']?['endValue'];

                                        priceRange =
                                            (priceStartValue != null &&
                                                priceEndValue != null)
                                            ? '₹$priceStartValue - ₹$priceEndValue'
                                            : null;

                                        // CARAT
                                        caratStartIndex =
                                            result['carat']?['startIndex'];
                                        caratEndIndex =
                                            result['carat']?['endIndex'];

                                        caratStartValue =
                                            result['carat']?['startValue'];
                                        caratEndValue =
                                            result['carat']?['endValue'];

                                        caratRange =
                                            (caratStartValue != null &&
                                                caratEndValue != null)
                                            ? '$caratStartValue - $caratEndValue ct'
                                            : null;

                                        // COLOR
                                        colorStartIndex =
                                            result['color']?['startIndex'];
                                        colorEndIndex =
                                            result['color']?['endIndex'];

                                        colorStart =
                                            result['color']?['start']; // ✅ FIX
                                        colorEnd =
                                            result['color']?['end']; // ✅ FIX

                                        colorRange =
                                            colorStart != null &&
                                                colorEnd != null
                                            ? '$colorStart - $colorEnd'
                                            : null;

                                        // CLARITY
                                        clarityStartIndex =
                                            result['clarity']?['startIndex'];
                                        clarityEndIndex =
                                            result['clarity']?['endIndex'];

                                        clarityStart =
                                            result['clarity']?['start']; // ✅ FIX
                                        clarityEnd =
                                            result['clarity']?['end']; // ✅ FIX

                                        clarityRange =
                                            clarityStart != null &&
                                                clarityEnd != null
                                            ? '$clarityStart - $clarityEnd'
                                            : null;

                                        ringSize = result['ringSize'];
                                      });

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Customization applied',
                                          ),
                                          backgroundColor: Color(0xFF90DCD0),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },

                                    //child: const Text('Customize Solitaire'),
                                    child: Stack(
                                      children: [
                                        /// Outer border
                                        Positioned.fill(
                                          child: Container(
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: const BorderSide(
                                                  width: 1,
                                                  color: Color(0xFF6C5022),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                          ),
                                        ),

                                        /// Main button
                                        Positioned(
                                          left: 4 * r,
                                          top: 4 * r,
                                          bottom: 4 * r,
                                          right: 84 * r,
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFFCBC4AE),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      15 * r,
                                                    ),
                                              ),
                                            ),
                                            child: MyText(
                                              'Start customizing',
                                              style: TextStyle(
                                                color: Color(0xFF6C5022),
                                                fontSize: 14 * r,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),

                                        /// Arrow image button
                                        Positioned(
                                          top: 4 * r,
                                          bottom: 4 * r,
                                          right: 4 * r,
                                          width: 72 * r,
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFF6C5022),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      15 * r,
                                                    ),
                                              ),
                                            ),
                                            child: Image.asset(
                                              'assets/jewellery_pdp/cus-ticon.png',
                                              width: 18 * r,
                                              height: 18 * r,
                                            ),
                                          ),
                                        ),
                                        //),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        height: 82 * r,
        padding: EdgeInsets.symmetric(horizontal: 40 * r),
        decoration: BoxDecoration(
          color: Color(0xFFBEE4DD),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25 * r),
            topRight: Radius.circular(25 * r),
          ),
          border: Border(top: BorderSide(color: Color(0xFF90DCD0), width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// PRICE TEXT
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //const Spacer(),
                MyText(
                  'Approx.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20 * r,
                    color: const Color(0xFF757575),
                    fontFamily: 'Montserrat',
                    height: 1.35 * r,
                    letterSpacing: 0.40 * r,
                  ),
                ),
                SizedBox(width: 30 * r),
                Row(
                  children: [
                    MyText(
                      '₹1,02,150',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30 * r,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        height: 0.90 * r,
                        letterSpacing: 0.60 * r,
                      ),
                    ),
                    const SizedBox(width: 6),
                    MyText(
                      '-',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30 * r,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        height: 0.90 * r,
                        letterSpacing: 0.60 * r,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '₹1,30,150',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30 * r,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        height: 0.90 * r,
                        letterSpacing: 0.60 * r,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            /// CONTINUE BUTTON
            InkWell(
              onTap: () {
                // TODO: navigate to next screen
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 258 * r,
                height: 52 * r,
                padding: EdgeInsets.symmetric(
                  horizontal: 30 * r,
                  vertical: 6 * r,
                ),
                decoration: ShapeDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(0.0, 0.5),
                    end: Alignment(0.96, 1.12),
                    colors: [Color(0xFFBEE4DD), Color(0xA5D1B193)],
                  ),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFFACA584)),
                    borderRadius: BorderRadius.circular(20 * r),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x7C000000),
                      blurRadius: 4,
                      offset: Offset(2, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: MyText(
                    'Continue ',
                    style: TextStyle(
                      color: const Color(0xFF6C5022),
                      fontSize: 20 * r,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            //SizedBox(width: 28 * r),
          ],
        ),
      ),
    );
  }
}

class DeliveryBadge extends StatelessWidget {
  final double r;
  const DeliveryBadge({super.key, required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 271 * r,
      height: 36 * r,
      decoration: BoxDecoration(
        color: const Color(0xFFBEE4DD),
        borderRadius: BorderRadius.circular(10 * r),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Row(
        children: [
          // Left text
          Expanded(
            child: Center(
              child: MyText(
                'Made to order',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF6C5022),
                  fontSize: 12 * r,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          // White separator
          Container(
            width: 1,
            margin: EdgeInsets.symmetric(vertical: 6 * r),
            color: Colors.white,
          ),

          // Right text
          Expanded(
            child: Center(
              child: MyText(
                'Est delivery 15 days',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF6C5022),
                  fontSize: 12 * r,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
