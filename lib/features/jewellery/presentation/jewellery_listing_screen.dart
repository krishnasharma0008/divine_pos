import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/app_bar.dart';
import '../../../shared/routes/app_drawer.dart';
import '../../../shared/utils/scale_size.dart';
import '../../../shared/utils/enums.dart';
import '../../../shared/widgets/text.dart';

import '../../auth/data/auth_notifier.dart';
import '../data/listing_provider.dart';
import '../data/jewellery_notifier.dart';
import '../data/jewellery_model.dart';
import '../data/filter_provider.dart';
import '../data/ui_providers.dart';

import 'top_buttons_row.dart';
import 'filter_sidebar.dart';
import 'category_section.dart';
import 'filter_tags_section.dart';
import 'product_grid.dart';

class JewelleryListingScreen extends ConsumerStatefulWidget {
  const JewelleryListingScreen({super.key});

  @override
  ConsumerState<JewelleryListingScreen> createState() =>
      _JewelleryListingScreenState();
}

class _JewelleryListingScreenState
    extends ConsumerState<JewelleryListingScreen> {
  bool isStoreApiCalled = false;
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

    /// 🔹 Infinite scroll
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

    final jewelleryNotifier = ref.read(jewelleryProvider.notifier);
    final filterNotifier = ref.read(filterProvider.notifier);

    return Scaffold(
      appBar: MyAppBar(
        appBarLeading: AppBarLeading.drawer,
        showLogo: false,
        actions: [
          AppBarActionConfig(type: AppBarAction.search, onTap: () {}),
          AppBarActionConfig(
            type: AppBarAction.notification,
            badgeCount: 1,
            onTap: () => context.push('/notifications'),
          ),
          AppBarActionConfig(
            type: AppBarAction.profile,
            onTap: () => context.push('/profile'),
          ),
          AppBarActionConfig(
            type: AppBarAction.cart,
            badgeCount: 2,
            onTap: () => context.push('/cart'),
          ),
        ],
      ),

      drawer: const SideDrawer(),

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

                    filterNotifier.setProductsAtOtherBranch(store.code);
                    jewelleryNotifier.resetAndFetch();
                  },

                  onSortSelected: (sort) {
                    filterNotifier.setSort(sort);
                    jewelleryNotifier.resetAndFetch();
                  },

                  onTabSelected: (tab) {
                    if (tab == 0) {
                      filterNotifier.setProductsInStore();
                    } else if (tab == 2) {
                      filterNotifier.setAllDesigns();
                    }

                    jewelleryNotifier.resetAndFetch();
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
                            const CategorySection(),
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
                                    isLoadingMore:
                                        jewelleryNotifier.isLoadingMore,
                                  );
                                },
                              ),
                            ),

                            /// 🔹 LOAD MORE INDICATOR
                            if (jewelleryNotifier.isLoadingMore)
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
