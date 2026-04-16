import 'package:divine_pos/features/cart/data/customer_detail_model.dart';
import 'package:divine_pos/features/jewellery/data/add_to_cart_notifier.dart';
//import 'package:divine_pos/features/jewellery/data/branch_provider.dart';
import 'package:divine_pos/features/jewellery_customize/presentation/widget/continue_cart_popup.dart';
import 'package:divine_pos/features/solitaire_customize/data/solitaire_detail_model.dart';
import 'package:divine_pos/shared/routes/route_pages.dart';
//import 'package:divine_pos/shared/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
//import 'package:collection/collection.dart';

import '../../../shared/app_bar.dart';
import '../../../shared/routes/app_drawer.dart';
import '../../../shared/utils/enums.dart';
import '../../../shared/utils/scale_size.dart';
import '../../../shared/widgets/text.dart';

import '../../auth/data/auth_notifier.dart';
import '../data/filter_provider.dart';
import '../data/jewellery_provider.dart';
import '../data/listing_provider.dart';
import '../data/jewellery_model.dart';

import 'top_buttons_row.dart';
import 'filter_sidebar.dart';
import 'category_section.dart';
import 'filter_tags_section.dart';
import 'product_grid.dart'; // for jewellery product listing screen
import 'solitaire_products.dart'; //for solitaire product listing screen
import 'package:divine_pos/shared/utils/jewellery_utils.dart'; // for shape code to name mapping

class JewelleryListingScreen extends ConsumerStatefulWidget {
  const JewelleryListingScreen({
    super.key,
    required this.paramKey,
    required this.paramValue,
  });

  final JewelleryProductKey? paramKey;
  final String? paramValue;

  @override
  ConsumerState<JewelleryListingScreen> createState() =>
      _JewelleryListingScreenState();
}

class _JewelleryListingScreenState
    extends ConsumerState<JewelleryListingScreen> {
  final _scrollController = ScrollController();
  String pjcode = '';
  //bool _routeApplied = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      final filterNotifier = ref.read(filterProvider.notifier);

      filterNotifier.setProductsInStore();
      filterNotifier.resetFilters();

      if (widget.paramKey != null && widget.paramValue != null) {
        if (widget.paramKey == JewelleryProductKey.category) {
          filterNotifier.setCategory(widget.paramValue!);
        }
        if (widget.paramKey == JewelleryProductKey.collection) {
          filterNotifier.setSubCategory(widget.paramValue!);
        }
      }

      filterNotifier.markInitialized();
      ref.read(jewelleryProvider.notifier).resetAndFetch();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final auth = ref.read(authProvider);
      final raw = auth.user?.pjcode ?? '';
      final code = raw.split(',').first.trim();

      setState(() {
        pjcode = code;
      });

      final storeNotifier = ref.read(storeProvider.notifier);
      storeNotifier.getPJStore(pjcode: pjcode);
      storeNotifier.getFilters();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final notifier = ref.read(jewelleryProvider.notifier);

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        notifier.hasMore &&
        !notifier.isLoadingMore) {
      notifier.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print("xx: ${widget.paramKey}: ${widget.paramValue}");
    final fem = ScaleSize.aspectRatio;

    final storeState = ref.watch(storeProvider);
    final filters =
        storeState.filters; // for categories, sub-categories, collections
    final jewelleryAsync = ref.watch(jewelleryProvider);
    final jewelleryNotifier = ref.read(jewelleryProvider.notifier);
    final filterNotifier = ref.read(filterProvider.notifier);

    final filter = ref.watch(filterProvider); // FilterState

    // ── Solitaire flag ──────────────────────────────────
    final isSolitaire = filter
        .selectedCategory // 👈 line 133
        .any((c) => c.trim().toLowerCase() == 'solitaires');

    // / find store where code == pjcode
    // final matchedStore = storeState.stores.firstWhereOrNull(
    //   (store) => store.code == pjcode,
    // );

    // find store where code != pjcode
    final branchStores = storeState.stores
        .where((store) => store.code != pjcode)
        .toList();

    // final selectedBranch = storeState.selectedStore?.nickName ?? '';
    // final customerid = matchedStore?.customerID;
    // final customername = matchedStore?.name;
    // final customercode = matchedStore?.code;

    // debugPrint('Selected branch: $selectedBranch');
    // debugPrint('customerid : $customerid');
    // debugPrint('customercode : $customercode');
    // debugPrint('customername : $customername');

    // ────────────────────────────────────────────────────

    final showInitialLoader =
        storeState.isLoading ||
        (jewelleryAsync.isLoading && !jewelleryNotifier.isLoadingMore);

    final cartCount = ref.watch(authProvider).user?.cartCount ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(
        appBarLeading: AppBarLeading.drawer,
        //appBarLeading: AppBarLeading.back,
        showLogo: false,
        actions: [
          AppBarActionConfig(type: AppBarAction.search, onTap: () {}),
          // AppBarActionConfig(
          //   type: AppBarAction.notification,
          //   badgeCount: 0,
          //   onTap: () => context.push('/notifications'),
          // ),
          AppBarActionConfig(
            type: AppBarAction.profile,
            onTap: () => context.pushNamed(
              RoutePages.profile.routeName,
            ), // context.push('/profile'),
          ),
          AppBarActionConfig(
            type: AppBarAction.cart,
            badgeCount: cartCount,
            onTap: () => context.pushNamed(
              RoutePages.cart.routeName,
            ), //context.push('/cart'),
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
                  branchStores: branchStores,
                  //isSolitaire: isSolitaire ? true : false,
                  isSolitaire: isSolitaire,
                  // onBranchSelected: (store) {
                  //   ref.read(storeProvider.notifier).selectStore(store);
                  //   filterNotifier.setProductsAtOtherBranch(store.code);
                  // },
                  onBranchSelected: (store) {
                    if (store == null) {
                      filterNotifier.setAllStore();
                    } else {
                      ref.read(storeProvider.notifier).selectStore(store);
                      filterNotifier.setProductsAtOtherBranch(store.code);
                    }

                    //jewelleryNotifier.resetAndFetch();
                  },
                  onSortSelected: (sort) {
                    filterNotifier.setSort(sort);
                    jewelleryNotifier.resetAndFetch();
                  },
                  onTabSelected: (tab) {
                    if (tab == 0) {
                      filterNotifier.setProductsInStore();
                    }
                    // else if (tab == 1) {
                    //   filterNotifier.setAllStore();
                    // }
                    else if (tab == 1) {
                      filterNotifier.setAllDesigns();
                    }
                    //jewelleryNotifier.resetAndFetch();
                  },
                ),

                /// 🔹 Main content
                Expanded(
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: fem * 5,
                          //right: fem * 20,
                        ),
                        //child: const FilterSidebar(),
                        child: FilterSidebar(
                          categories: filters.categories,
                          subCategories: filters.subCategories,
                          collections: filters.collections,
                        ),
                      ),

                      Expanded(
                        child: Column(
                          children: [
                            CategorySection(),
                            FilterTagsSection(),
                            SizedBox(height: fem * 10),
                            Expanded(
                              child: isSolitaire
                                  // // ── SOLITAIRE VIEW ──────────────────────
                                  // ? _SolitaireListView(
                                  //     scrollController: _scrollController,
                                  //     fem: fem,
                                  //   )
                                  //── SOLITAIRE VIEW ──────────────────────
                                  ? jewelleryAsync.when(
                                      loading: () => const SizedBox(),
                                      error: (err, _) => Center(
                                        child: MyText(
                                          err.toString(),
                                          style: TextStyle(
                                            fontSize: 16 * fem,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      data: (jewellery) {
                                        // जरूरत हो तो सिर्फ solitaire items filter कर

                                        // debugPrint(
                                        //   'Solitaire data length: ${jewellery.length}',
                                        // );
                                        // for (final j in jewellery) {
                                        //   debugPrint(
                                        //     'designno=${j.designno}, category=${j.productCategory}, shape=${j.shape}, weight=${j.weight}, price=${j.price}',
                                        //   );
                                        // }
                                        final solitaireItems = jewellery
                                            .where(
                                              (e) =>
                                                  (e.designno ?? '')
                                                      .toUpperCase() ==
                                                  'SOL',
                                            )
                                            .toList();
                                        if (solitaireItems.isEmpty) {
                                          return Center(
                                            child: GestureDetector(
                                              onTap: () {
                                                context.pushNamed(
                                                  RoutePages
                                                      .solitairecustomize
                                                      .routeName,
                                                  extra: null,
                                                );
                                              },
                                              child: const MyText(
                                                'No loose solitaire at store. Please click here to customize.',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  color: Color(0xFF6C5022),
                                                ),
                                              ),
                                            ),
                                          );
                                        }

                                        // debugPrint(
                                        //   'customerid : ${customerid}',
                                        // );
                                        // debugPrint(
                                        //   'customercode : ${customercode}',
                                        // );
                                        // debugPrint(
                                        //   'customername : ${customername}',
                                        // );
                                        // debugPrint(
                                        //   'Selectedbranch : ${Selectedbranch}',
                                        // );

                                        return _SolitaireListView(
                                          scrollController: _scrollController,
                                          fem: fem,
                                          items:
                                              solitaireItems, // ← वही DB data
                                        );
                                      },
                                    )
                                  // ── JEWELLERY VIEW ──────────────────────
                                  : jewelleryAsync.when(
                                      loading: () => const SizedBox(),
                                      error: (err, _) => Center(
                                        child: MyText(
                                          err.toString(),
                                          style: TextStyle(
                                            fontSize: 16 * fem,
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
              color: Colors.black.withValues(alpha: 0.15),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Solitaire list view — shown when category == "Solitaires"
// Replace the dummy data below with your real provider/model when ready.
// ─────────────────────────────────────────────────────────────────────────────

class _SolitaireListView extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final double fem;
  final List<Jewellery> items;
  // final int customerid;
  // final String customercode;
  // final String customername;
  // final String Selectedbranch;

  const _SolitaireListView({
    required this.scrollController,
    required this.fem,
    required this.items,
    // required this.customerid,
    // required this.customercode,
    // required this.customername,
    // required this.Selectedbranch,
  });

  @override
  ConsumerState<_SolitaireListView> createState() => _SolitaireListViewState();
}

class _SolitaireListViewState extends ConsumerState<_SolitaireListView> {
  late List<int> _pcs; // हर row की qty

  @override
  void initState() {
    super.initState();
    _pcs = List.filled(widget.items.length, 0);
  }

  @override
  void didUpdateWidget(_SolitaireListView old) {
    // 👈 add here
    super.didUpdateWidget(old);
    if (old.items.length != widget.items.length) {
      _pcs = List.filled(widget.items.length, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // ── Scrollable content ───────────────────────────────────────────
          Expanded(
            child: CustomScrollView(
              controller: widget.scrollController,
              slivers: [
                // ── Pinned header ──────────────────────────────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SolitaireHeaderDelegate(fem: widget.fem),
                ),
                // ── Rows ───────────────────────────────────────────────────
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * widget.fem),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      //final item = _items[index];
                      final j = widget.items[index];
                      final qty = _pcs[index];
                      return DiamondsRow(
                        srNo: index + 1,
                        shape: JewelleryUtils.mapShapeCodeToName(j.shape ?? ''),
                        color: j.color ?? '',
                        clarity: j.clarity ?? '',
                        carat: j.weight ?? 0,
                        price: (j.price ?? 0).toDouble(),
                        qty: qty,
                        onInc: () => setState(() => _pcs[index]++),
                        onDec: () => setState(() {
                          if (_pcs[index] > 0) _pcs[index]--;
                        }),
                        onCart: () async {
                          // final customer = await showDialog<CustomerDetail>(
                          //   context: context,
                          //   barrierDismissible: true,
                          //   builder: (_) =>
                          //       ContinueCartPopup(parentContext: context),
                          // );
                          final customer = await showDialog<CustomerDetail>(
                            context: context,
                            barrierDismissible: true,
                            builder: (dialogContext) =>
                                ContinueCartPopup(parentContext: context),
                          );
                          if (customer == null) return;

                          final selectedRows = <Jewellery>[];
                          final item = widget.items[index];
                          selectedRows.add(item);

                          await ref
                              .read(addToCartProvider.notifier)
                              .createCartFromRows(
                                rows: selectedRows,
                                customerOrder: customer,
                                // customerid: widget.customerid,
                                // customercode: widget.customercode,
                                // customername: widget.customername,
                                // branch: widget.Selectedbranch,
                              );

                          if (!context.mounted) return;

                          // ✅ Read the inner AddToCartState from AsyncValue
                          final result = ref.read(addToCartProvider).value;

                          if (result?.isSuccess == true) {
                            // ✅ Reset so next add starts fresh
                            ref.read(addToCartProvider.notifier).reset();
                            context.pushNamed(RoutePages.cart.routeName);
                          } else if (result?.isError == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result?.errorMessage ??
                                      'Failed to add to cart',
                                ),
                              ),
                            );
                          }
                        },
                        onCustomise: () {
                          final j = widget.items[index];
                          final detail = SolitaireDetail(
                            itemId: j.itemId ?? 0,
                            itemNumber: j.itemNumber ?? '',
                            designNo: j.designno ?? '',
                            oldVariant: j.oldVariant ?? '',
                            productCategory: j.productCategory ?? '',
                            solitaireSlab: j.solitaireSlab ?? '',
                            weight: (j.weight ?? 0).toDouble(),
                            pcs: 1,
                            isNew: j.isNew ?? false,
                            classify: j.classify,
                            description: j.description,
                            price: (j.price ?? 0).toDouble(),
                            layingWith: j.laying_with ?? '',
                            shape: j.shape ?? '',
                            color: j.color ?? '',
                            clarity: j.clarity ?? '',
                            imageUrl: j.imageUrl ?? '',
                          );
                          context.pushNamed(
                            RoutePages.solitairecustomize.routeName,
                            extra: detail,
                          );
                        },
                        // onCustomise: () {
                        //   context.pushNamed(
                        //     RoutePages.solitairecustomize.routeName,
                        //     queryParameters: {
                        //       'productCode': j.itemNumber ?? '',
                        //       'layingwith': j.laying_with,
                        //     },
                        //   );
                        // },
                      );
                    }, childCount: widget.items.length),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom bar — Figma: mint bg, rounded top corners ─────────────
          // Builder(
          //   builder: (context) {
          //     // Calculate grand total across all items
          //     double grandTotal = 0;
          //     for (int i = 0; i < widget.items.length; i++) {
          //       grandTotal +=
          //           (widget.items[i].price ?? 0).toDouble() *
          //           _pcs[i] *
          //           (widget.items[i].weight ?? 0).toDouble();
          //     }

          //     return Container(
          //       height: 82 * widget.fem,
          //       padding: EdgeInsets.symmetric(horizontal: 24 * widget.fem),
          //       decoration: ShapeDecoration(
          //         color: Color(0xFFBEE4DD),
          //         shape: RoundedRectangleBorder(
          //           side: BorderSide(width: 1, color: Color(0xFF90DCD0)),
          //           borderRadius: BorderRadius.only(
          //             topLeft: Radius.circular(25 * widget.fem),
          //             topRight: Radius.circular(25 * widget.fem),
          //           ),
          //         ),
          //       ),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           // ── Total label + amount ─────────────────────────────
          //           Column(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               // const Text(
          //               //   'Total Amount',
          //               //   style: TextStyle(
          //               //     color: Color(0xFF888888),
          //               //     fontSize: 13,
          //               //     fontFamily: 'Arial',
          //               //     fontWeight: FontWeight.w400,
          //               //   ),
          //               // ),
          //               // const SizedBox(height: 2),
          //               MyText(
          //                 grandTotal.inRupeesFormat(),
          //                 style: TextStyle(
          //                   color: Color(0xFF333333),
          //                   fontSize: 18 * widget.fem,
          //                   fontFamily: 'Arial',
          //                   fontWeight: FontWeight.w600,
          //                 ),
          //               ),
          //             ],
          //           ),

          //           // ── Place Order button ───────────────────────────────
          //           InkWell(
          //             onTap: () async {
          //               final customer = await showDialog<CustomerDetail>(
          //                 context: context,
          //                 barrierDismissible: true,
          //                 builder: (_) =>
          //                     ContinueCartPopup(parentContext: context),
          //               );
          //               if (customer == null) return;

          //               final selectedRows = <Jewellery>[];
          //               for (var i = 0; i < widget.items.length; i++) {
          //                 final qty = _pcs[i];
          //                 if (qty > 0) {
          //                   final updated = widget.items[i].copyWith(pcs: qty);
          //                   selectedRows.add(updated);
          //                 }
          //               }

          //               if (selectedRows.isEmpty) {
          //                 debugPrint('No items with qty > 0');
          //                 return;
          //               }
          //               await ref
          //                   .read(addToCartProvider.notifier)
          //                   .createCartFromRows(
          //                     rows: selectedRows,
          //                     customerOrder: customer,
          //                     customerid: widget.customerid,
          //                     customercode: widget.customercode,
          //                     customername: widget.customername,
          //                     branch: widget.Selectedbranch,
          //                   );

          //               if (!context.mounted) return;

          //               // ✅ Read the inner AddToCartState from AsyncValue
          //               final result = ref.read(addToCartProvider).value;

          //               if (result?.isSuccess == true) {
          //                 // ✅ Reset so next add starts fresh
          //                 ref.read(addToCartProvider.notifier).reset();
          //                 context.pushNamed(RoutePages.cart.routeName);
          //               } else if (result?.isError == true) {
          //                 ScaffoldMessenger.of(context).showSnackBar(
          //                   SnackBar(
          //                     content: Text(
          //                       result?.errorMessage ?? 'Failed to add to cart',
          //                     ),
          //                   ),
          //                 );
          //               }
          //             },
          //             borderRadius: BorderRadius.circular(20 * widget.fem),
          //             child: Container(
          //               width: 258 * widget.fem,
          //               height: 52 * widget.fem,
          //               padding: EdgeInsets.symmetric(
          //                 horizontal: 30 * widget.fem,
          //                 vertical: 6 * widget.fem,
          //               ),
          //               decoration: ShapeDecoration(
          //                 gradient: const LinearGradient(
          //                   begin: Alignment(0.0, 0.5),
          //                   end: Alignment(0.96, 1.12),
          //                   colors: [Color(0xFFBEE4DD), Color(0xA5D1B193)],
          //                 ),
          //                 shape: RoundedRectangleBorder(
          //                   side: const BorderSide(
          //                     width: 1,
          //                     color: Color(0xFFACA584),
          //                   ),
          //                   borderRadius: BorderRadius.all(Radius.circular(20)),
          //                 ),
          //                 shadows: [
          //                   BoxShadow(
          //                     color: Color(0x7C000000),
          //                     blurRadius: 4 * widget.fem,
          //                     offset: Offset(2, 2),
          //                     spreadRadius: 0,
          //                   ),
          //                 ],
          //               ),
          //               child: Center(
          //                 child: MyText(
          //                   'Continue',
          //                   style: TextStyle(
          //                     color: const Color(0xFF6C5022),
          //                     fontSize: 20 * widget.fem,
          //                     fontFamily: 'Montserrat',
          //                     fontWeight: FontWeight.w500,
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}

// ── Delegate that keeps SolitaireHeader pinned at the top ────────────────────
class _SolitaireHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double fem;

  _SolitaireHeaderDelegate({required this.fem});

  @override
  double get minExtent => 68 * fem; // 61 height + 8 top + 8 bottom padding

  @override
  double get maxExtent => 68 * fem;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    //final fem = ScaleSize.aspectRatio;
    return Container(
      color: Colors.white, // prevents content bleeding through when pinned
      padding: EdgeInsets.symmetric(horizontal: 8 * fem, vertical: 0 * fem),
      child: const SolitaireHeader(),
    );
  }

  @override
  bool shouldRebuild(covariant _SolitaireHeaderDelegate oldDelegate) => false;
}

void longPrint(Object? obj) {
  const chunkSize = 800;
  final str = obj.toString();
  for (var i = 0; i < str.length; i += chunkSize) {
    final end = (i + chunkSize < str.length) ? i + chunkSize : str.length;
    debugPrint(str.substring(i, end));
  }
}
