import 'package:flutter/material.dart';
import 'top_buttons_row.dart';
import 'filter_sidebar.dart';
import 'category_section.dart';
import 'filter_tags_section.dart';
import 'product_grid.dart';
import '../../auth/data/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/listing_provider.dart';
import "../data/jewellery_model.dart";
import '../../../shared/app_bar.dart';
import '../../../shared/widgets/text.dart'; // ✅ Import MyText

class JewelleryListingScreen extends ConsumerStatefulWidget {
  const JewelleryListingScreen({super.key});

  @override
  ConsumerState<JewelleryListingScreen> createState() =>
      _JewelleryListingScreenState();
}

class _JewelleryListingScreenState
    extends ConsumerState<JewelleryListingScreen> {
  String? pjcode;
  bool isApiCalled = false;
  String? _selectedSort;

  // Dummy products list
  final List<Map<String, dynamic>> products = [
    {
      "image": "assets/jewellery/filter_tags/rings.jpg",
      "title": "Eternal Balance Ring For Hera Symbol Of Brilliance, Balance.",
      "price": "₹ 50,000",
      "tagText": "Best Seller 🔥",
      "tagColor": Colors.orange,
      "soldOut": true,
    },
    {
      "image": "assets/jewellery/filter_tags/mangalsutra.png",
      "title": "Eternal Radiance Necklace For Hera Symbol Of Brilliance.",
      "price": "₹ 1,10,000",
      "tagText": "New Arrival ✨",
      "tagColor": Colors.teal,
      "soldOut": false,
    },
    {
      "image": "assets/jewellery/filter_tags/earrings.png",
      "title": "Eternal Radiance Earrings For Hera.",
      "price": "₹ 90,000",
      "tagText": "Trending 🔥",
      "tagColor": Colors.green,
      "soldOut": false,
    },
    {
      "image": "assets/jewellery/filter_tags/nosepin.png",
      "title": "Eternal Radiance Pendant For Hera.",
      "price": "₹ 59,000",
      "tagText": "Best Seller 🔥",
      "tagColor": Colors.orange,
      "soldOut": false,
    },
    {
      "image": "assets/jewellery/filter_tags/bangles.png",
      "title": "Eternal Radiance Ring for Hera symbol of brilliance, balance.",
      "price": "₹ 59,000",
      "tagText": "Best Seller 🔥",
      "tagColor": Colors.orange,
      "soldOut": false,
    },
  ];

  @override
  void initState() {
    super.initState();

    /// SAFE API call using microtask
    Future.microtask(() {
      final authRepo = ref.read(authProvider);

      pjcode = authRepo.user?.pjcode;

      if (pjcode != null && !isApiCalled) {
        ref.read(StoreProvider.notifier).getPJStore(pjcode: pjcode!);
        isApiCalled = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = ref.watch(authProvider);
    pjcode = authRepo.user?.pjcode;

    final storeState = ref.watch(StoreProvider);

    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        showSearch: false, // ✅ optional
        showLogo: false, // ✅ optional
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                /// Top thin loader
                if (storeState.isLoading)
                  const LinearProgressIndicator(minHeight: 3),

                /// MAIN TOP BUTTONS ROW
                TopButtonsRow(
                  branchStores: storeState.stores,
                  onBranchSelected: (selectedStore) {
                    ref.read(StoreProvider.notifier).selectStore(selectedStore);
                    debugPrint(
                      "Selected branch store: ${selectedStore.name} (${selectedStore.code})",
                    );
                  },
                  onSortSelected: (sortValue) {
                    setState(() => _selectedSort = sortValue);
                    debugPrint("Selected sort: $sortValue");
                  },
                  onTabSelected: (index) {
                    debugPrint("Tab clicked: $index");
                  },
                ),

                /// MAIN BODY SECTION
                Expanded(
                  child: Row(
                    children: [
                      /// LEFT SIDE FILTER PANEL
                      const FilterSidebar(),

                      /// RIGHT SIDE CONTENT
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 29),
                            const CategorySection(),
                            const SizedBox(height: 31),
                            const FilterTagsSection(),

                            Expanded(child: ProductGrid(products: products)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// DARK OVERLAY WITH SPINNER
          if (storeState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.15),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
  //   @override
  //   Widget build(BuildContext context) {
  //     final authRepo = ref.watch(authProvider);
  //     pjcode = authRepo.user?.pjcode;

  //     final storeState = ref.watch(StoreProvider);

  //     return Stack(
  //       children: [
  //         Scaffold(
  //           body: SafeArea(
  //             child: Column(
  //               children: [
  //                 /// Top thin loader
  //                 if (storeState.isLoading)
  //                   const LinearProgressIndicator(minHeight: 3),

  //                 /// MAIN TOP BUTTONS ROW
  //                 TopButtonsRow(
  //                   branchStores: storeState.stores,
  //                   onBranchSelected: (selectedStore) {
  //                     ref.read(StoreProvider.notifier).selectStore(selectedStore);
  //                     debugPrint(
  //                       "Selected branch store: ${selectedStore.name} (${selectedStore.code})",
  //                     );
  //                   },
  //                   onSortSelected: (sortValue) {
  //                     setState(() => _selectedSort = sortValue);
  //                     debugPrint("Selected sort: $sortValue");
  //                   },
  //                   onTabSelected: (index) {
  //                     debugPrint("Tab clicked: $index");
  //                   },
  //                 ),

  //                 /// MAIN BODY SECTION
  //                 Expanded(
  //                   child: Row(
  //                     children: [
  //                       /// LEFT SIDE FILTER PANEL
  //                       const FilterSidebar(),

  //                       /// RIGHT SIDE CONTENT
  //                       Expanded(
  //                         child: Column(
  //                           children: [
  //                             const SizedBox(height: 29),
  //                             const CategorySection(),
  //                             const SizedBox(height: 31),
  //                             const FilterTagsSection(),

  //                             Expanded(child: ProductGrid(products: products)),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),

  //         /// DARK OVERLAY WITH SPINNER (for API loading)
  //         if (storeState.isLoading)
  //           Container(
  //             color: Colors.black.withOpacity(0.15),
  //             child: const Center(child: CircularProgressIndicator()),
  //           ),
  //       ],
  //     );
  //   }
  // }
