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

class JewelleryJourneyScreen extends StatefulWidget {
  const JewelleryJourneyScreen({super.key});

  @override
  State<JewelleryJourneyScreen> createState() => _JewelleryJourneyScreenState();
}

class _JewelleryJourneyScreenState extends State<JewelleryJourneyScreen> {
  int activeTab = 0;

  @override
  Widget build(BuildContext context) {
    final r = ScaleSize.aspectRatio;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: MyAppBar(
        appBarLeading: AppBarLeading.back,
        showLogo: false,
        // actions: [
        //   AppBarActionConfig(type: AppBarAction.search, onTap: () {}),
        //   AppBarActionConfig(
        //     type: AppBarAction.notification,
        //     badgeCount: 1,
        //     onTap: () => context.push('/notifications'),
        //   ),
        //   AppBarActionConfig(
        //     type: AppBarAction.profile,
        //     onTap: () => context.push('/profile'),
        //   ),
        //   AppBarActionConfig(
        //     type: AppBarAction.cart,
        //     badgeCount: 2,
        //     onTap: () => context.push('/cart'),
        //   ),
        // ],
      ),
      //drawer: const SideDrawer(),
      body: Container(
        //width: 1194 * r,
        width: double.infinity,
        //height: 834 * r,
        decoration: BoxDecoration(
          color: Colors.white,
          //borderRadius: BorderRadius.circular(16 * r),
        ),
        child: Column(
          children: [
            //Divider(height: 1 * r),

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

                            //SizedBox(height: 18 * r),
                            DetailsScreen(r: r),

                            //SizedBox(height: 24 * r),

                            /// your button stack stays here
                            Padding(
                              //padding: const EdgeInsets.all(8.0),
                              padding: EdgeInsets.only(right: 34 * r),
                              child: Container(
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
                                            builder: (_) =>
                                                const CustomizeSolitaire(),
                                          );

                                      if (result != null) {
                                        final priceStart =
                                            result['price']['start'] as String;
                                        final priceEnd =
                                            result['price']['end'] as String;
                                        final caratStart =
                                            result['carat']['start'] as String;
                                        final caratEnd =
                                            result['carat']['end'] as String;
                                        final colorStart =
                                            result['color']['start'] as String;
                                        final colorEnd =
                                            result['color']['end'] as String;
                                        final clarityStart =
                                            result['clarity']['start']
                                                as String;
                                        final clarityEnd =
                                            result['clarity']['end'] as String;

                                        debugPrint(
                                          '✅ Applied Filters:\n'
                                          '💎 Price: ₹$priceStart - ₹$priceEnd\n'
                                          '💍 Carat: $caratStart - $caratEnd\n'
                                          '🎨 Color: $colorStart - $colorEnd\n'
                                          '✨ Clarity: $clarityStart - $clarityEnd',
                                        );

                                        // ✅ Safe snackbar (works in ConsumerWidget)
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Applied: $caratStart-$caratEnd carat',
                                              ),
                                              backgroundColor: const Color(
                                                0xFF90DCD0,
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      }
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
                                            // child: Transform.rotate(
                                            //   angle: -1.57,
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

            // Expanded(
            //   child: SingleChildScrollView(
            //     child: Padding(
            //       //padding: EdgeInsets.all(16 * r),
            //       padding: EdgeInsets.symmetric(
            //         horizontal: 12 * r,
            //         //vertical: 16 * r,
            //       ),
            //       child: Row(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           // LEFT PANEL: gallery + tabs stacked vertically
            //           Expanded(
            //             flex: 1,
            //             child: Column(
            //               children: [
            //                 SizedBox(
            //                   //height: 400 * r,
            //                   child: ImagePreviewWithThumbnails(
            //                     images: dummyProductImages,
            //                   ),
            //                 ),

            //                 SizedBox(height: 16 * r),
            //               ],
            //             ),
            //           ),

            //           SizedBox(width: 16 * r),

            //           // ✅ RIGHT PANEL — NOW EQUAL WIDTH
            //           Expanded(
            //             flex: 1,
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 SizedBox(height: 40 * r),
            //                 SizedBox(
            //                   width: 335 * r,
            //                   child: Text(
            //                     'Customize your Divine jewellery',
            //                     style: TextStyle(
            //                       color: Colors.black,
            //                       fontSize: 20 * r,
            //                       fontFamily: 'Rushter Glory',
            //                       fontWeight: FontWeight.w400,
            //                       height: 1.35,
            //                       letterSpacing: 0.40 * r,
            //                     ),
            //                   ),
            //                 ),
            //                 SizedBox(height: 18 * r),
            //                 TabRowWidget(
            //                   r,
            //                   activeTab: activeTab,
            //                   onTabSelected: (index) {
            //                     setState(() => activeTab = index);
            //                   },
            //                 ),

            //                 SizedBox(height: 18 * r),

            //                 CustomizationPanel(r, activeTab: activeTab),
            //               ],
            //             ),
            //             // child: SolitaireDetailsPanel(
            //             //   r: r,
            //             //   caratGrades: ["0.20", "0.25", "0.30", "0.40", "0.50"],
            //             //   colorGrades: ["D", "E", "F", "G", "H", "I"],
            //             //   clarityGrades: ["VVS1", "VVS2", "VS1", "VS2"],
            //             //   sizeGrades: ["12", "14", "16", "18"],
            //             // ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            /// BOTTOM PRICE BAR (fixed)
            //BottomBar(r),
          ],
        ),
      ),
    );
  }
}
