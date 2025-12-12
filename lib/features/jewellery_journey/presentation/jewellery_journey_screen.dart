import 'package:flutter/material.dart';
import '../../../shared/utils/scale_size.dart';
import 'package:go_router/go_router.dart';

import 'top_header.dart';
import 'image_preview_with_thumbnails.dart'; //gallery
import "../data/product_images.dart";
import 'customization_panel.dart'; //customization_panel
import 'button_bar.dart';
import 'tab_row.dart'; //tab panel

import 'solitaire_details_panel.dart';

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
    url: 'assets/jewellery/filter_tags/bangles.png',
    tagText: "Trending 🔥",
    tagColor: Colors.green,
  ),
  ProductImage(
    id: '4',
    url: 'assets/jewellery/filter_tags/mangalsutra.png',
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
      body: Center(
        child: Container(
          width: 1194 * r,
          height: 834 * r,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16 * r),
          ),
          child: Column(
            children: [
              /// HEADER (fixed)
              TopHeader(
                r,
                onBack: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
                onAddToCart: () {
                  debugPrint("Cart tapped");
                },
              ),

              Divider(height: 1 * r),

              /// SCROLLABLE MIDDLE
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    //padding: EdgeInsets.all(16 * r),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12 * r,
                      //vertical: 16 * r,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LEFT PANEL: gallery + tabs stacked vertically
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 400 * r,
                                child: ImagePreviewWithThumbnails(
                                  images: dummyProductImages,
                                ),
                              ),

                              SizedBox(height: 16 * r),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TabRowWidget(
                                    r,
                                    activeTab: activeTab,
                                    onTabSelected: (index) {
                                      setState(() => activeTab = index);
                                    },
                                  ),

                                  SizedBox(height: 18 * r),

                                  CustomizationPanel(r, activeTab: activeTab),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 16 * r),

                        /// ✅ RIGHT PANEL — NOW EQUAL WIDTH
                        Expanded(
                          flex: 1,
                          child: SolitaireDetailsPanel(
                            r: r,
                            caratGrades: [
                              "0.20",
                              "0.25",
                              "0.30",
                              "0.40",
                              "0.50",
                            ],
                            colorGrades: ["D", "E", "F", "G", "H", "I"],
                            clarityGrades: ["VVS1", "VVS2", "VS1", "VS2"],
                            sizeGrades: ["12", "14", "16", "18"],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// BOTTOM PRICE BAR (fixed)
              //BottomBar(r),
            ],
          ),
        ),
      ),
    );
  }
}
