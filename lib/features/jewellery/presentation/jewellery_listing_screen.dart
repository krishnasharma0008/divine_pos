import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/app_bar.dart';
import '../../../shared/routes/app_drawer.dart';
import '../../../shared/utils/enums.dart';
import '../../../shared/utils/scale_size.dart';
import '../../../shared/widgets/text.dart';

import '../../auth/data/auth_notifier.dart';
import '../data/filter_provider.dart';
import '../data/jewellery_notifier.dart';
import '../data/listing_provider.dart';

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
  final _scrollController = ScrollController();
  bool _routeApplied = false;

  @override
  void initState() {
    super.initState();

    /// 🔹 Fetch store list once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authProvider);
      final pjcode = auth.user?.pjcode;

      if (pjcode != null) {
        ref.read(StoreProvider.notifier).getPJStore(pjcode: pjcode);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeApplied) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final params = GoRouterState.of(context).uri.queryParameters;

      final category = params['category'];
      final collection = params['Collection'];

      final filter = ref.read(filterProvider.notifier);
      bool shouldFetch = false;

      if (category != null) {
        filter.setCategory(category);
        shouldFetch = true;
      }

      if (collection != null) {
        filter.setSubCategory(collection);
        shouldFetch = true;
      }

      if (shouldFetch) {
        ref.read(jewelleryProvider.notifier).resetAndFetch();
      }

      _routeApplied = true;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fem = ScaleSize.aspectRatio;

    final storeState = ref.watch(StoreProvider);
    final jewelleryAsync = ref.watch(jewelleryProvider);
    final jewelleryNotifier = ref.read(jewelleryProvider.notifier);
    final filterNotifier = ref.read(filterProvider.notifier);

    final showInitialLoader =
        storeState.isLoading ||
        (jewelleryAsync.isLoading && !jewelleryNotifier.isLoadingMore);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(
        appBarLeading: AppBarLeading.drawer,
        showLogo: false,
        actions: [
          AppBarActionConfig(type: AppBarAction.search, onTap: () {}),
          AppBarActionConfig(
            type: AppBarAction.notification,
            badgeCount: 0,
            onTap: () => context.push('/notifications'),
          ),
          AppBarActionConfig(
            type: AppBarAction.profile,
            onTap: () => context.push('/profile'),
          ),
          AppBarActionConfig(
            type: AppBarAction.cart,
            badgeCount: 0,
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
                /// 🔹 Top controls
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

                /// 🔹 Main content
                Expanded(
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: fem * 28,
                          right: fem * 40,
                        ),
                        child: const FilterSidebar(),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            CategorySection(),
                            FilterTagsSection(),
                            SizedBox(height: fem * 20),
                            Expanded(
                              child: jewelleryAsync.when(
                                loading: () => const SizedBox(),
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
                                        'No search results found, please try a different filter.',
                                        style: TextStyle(
                                          fontSize: 18,
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// 🔹 Initial loader only
          if (showInitialLoader)
            Container(
              color: Colors.black.withOpacity(0.15),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
