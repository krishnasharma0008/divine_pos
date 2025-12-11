import 'package:flutter/material.dart';
import 'top_buttons_row.dart';
import 'filter_sidebar.dart';
import 'category_section.dart';
import 'filter_tags_section.dart';
import 'product_grid.dart';
import '../../auth/data/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/listing_provider.dart';

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
  String? _selectedSort; // local sort dropdown value

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

    /// SAFE read auth + API
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

    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                if (storeState.isLoading)
                  const LinearProgressIndicator(minHeight: 3),

                TopButtonsRow(
                  branchStores: storeState.stores,
                  onBranchSelected: (selected) {
                    ref.read(StoreProvider.notifier).selectStore(selected);
                  },
                  onSortSelected: (sort) {
                    setState(() {
                      _selectedSort = sort; // update label
                    });
                    debugPrint("Selected sort: $sort");
                  },
                  onTabSelected: (index) => debugPrint("Tab: $index selected"),
                ),

                Expanded(
                  child: Row(
                    children: [
                      const FilterSidebar(),
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
        ),

        if (storeState.isLoading)
          Container(
            color: Colors.black.withOpacity(0.15),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
