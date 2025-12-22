import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/app_bar.dart';
import '../../../shared/utils/scale_size.dart';
import '../../../shared/utils/enums.dart';
import '../../../shared/widgets/text.dart';

import '../../auth/data/auth_notifier.dart';
import '../data/listing_provider.dart';
import '../data/jewellery_notifier.dart';
import '../data/jewellery_model.dart';

import 'top_buttons_row.dart';
import 'filter_sidebar.dart';
import 'category_section.dart';
import 'filter_tags_section.dart';
import 'product_grid.dart';

import '../data/filter_provider.dart';

class JewelleryListingScreen extends ConsumerStatefulWidget {
  const JewelleryListingScreen({super.key});

  @override
  ConsumerState<JewelleryListingScreen> createState() =>
      _JewelleryListingScreenState();
}

class _JewelleryListingScreenState
    extends ConsumerState<JewelleryListingScreen> {
  bool isStoreApiCalled = false;
  String? _selectedSort;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    /// 🔹 Store API (once)
    Future.microtask(() {
      final authRepo = ref.read(authProvider);
      final pjcode = authRepo.user?.pjcode;

      if (pjcode != null && !isStoreApiCalled) {
        ref.read(StoreProvider.notifier).getPJStore(pjcode: pjcode);
        isStoreApiCalled = true;
      }
    });

    /// 🔹 Scroll → Load More
    _scrollController.addListener(() {
      final notifier = ref.read(jewelleryProvider.notifier);

      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          notifier.hasMore &&
          !notifier.isLoadingMore) {
        notifier.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeState = ref.watch(StoreProvider);
    final jewelleryAsync = ref.watch(jewelleryProvider);

    return //Scaffold(
    //extendBodyBehindAppBar: true,
    // appBar: const CustomAppBar(
    //   showBackButton: true,
    //   showSearch: false,
    //   showLogo: false,
    // ),
    Scaffold(
      appBar: MyAppBar(showLogo: false, appBarLeading: AppBarLeading.back),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                if (storeState.isLoading)
                  const LinearProgressIndicator(minHeight: 3),

                /// 🔹 TOP CONTROLS
                TopButtonsRow(
                  branchStores: storeState.stores,
                  onBranchSelected: (store) {
                    ref.read(StoreProvider.notifier).selectStore(store);
                    ref
                        .read(filterProvider.notifier)
                        .setProductsAtOtherBranch(
                          store.code, // ✅ use class fields
                        );
                    //ref.read(jewelleryProvider.notifier).refresh();
                    ref.read(jewelleryProvider.notifier).resetAndFetch();
                  },

                  onSortSelected: (sort) {
                    ref.read(filterProvider.notifier).setSort(sort);
                    //ref.read(jewelleryProvider.notifier).refresh();
                    ref.read(jewelleryProvider.notifier).resetAndFetch();
                  },

                  onTabSelected: (tab) {
                    final filter = ref.read(filterProvider.notifier);

                    if (tab == 0) {
                      filter.setProductsInStore();
                    } else if (tab == 2) {
                      filter.setAllDesigns();
                    }

                    //ref.read(jewelleryProvider.notifier).refresh();
                  },
                ),

                /// 🔹 MAIN CONTENT
                Expanded(
                  child: Row(
                    children: [
                      const FilterSidebar(),

                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 9),
                            const CategorySection(),
                            const SizedBox(height: 9),
                            const FilterTagsSection(),

                            /// 🔹 LIST
                            Expanded(
                              child: jewelleryAsync.when(
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (err, _) => Center(
                                  child: MyText(
                                    err.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                data: (jewellery) {
                                  if (jewellery.isEmpty) {
                                    return const Center(
                                      child: MyText(
                                        "No jewellery found",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }

                                  return ProductGrid(
                                    jewellery: jewellery,
                                    controller: _scrollController,
                                    isLoadingMore: ref
                                        .watch(jewelleryProvider.notifier)
                                        .isLoadingMore,
                                  );
                                },
                              ),
                            ),

                            /// 🔹 LOAD MORE INDICATOR
                            if (ref
                                .watch(jewelleryProvider.notifier)
                                .isLoadingMore)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

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
