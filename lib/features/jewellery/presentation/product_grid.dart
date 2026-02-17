import 'package:divine_pos/features/auth/data/auth_notifier.dart';
import 'package:divine_pos/features/jewellery/data/add_to_cart_notifier.dart';
import 'package:divine_pos/features/jewellery/data/filter_provider.dart';
import 'package:divine_pos/features/jewellery/data/listing_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_card.dart';
import '../data/jewellery_model.dart';
import '../../../shared/utils/jewellery_helpers.dart';
import '../../../shared/utils/scale_size.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/routes/route_pages.dart';
import 'package:divine_pos/features/cart/data/customer_detail_model.dart';
import 'package:divine_pos/features/jewellery_customize/presentation/widget/continue_cart_popup.dart'; // customer selection and add to cart logic will be implemented here later

class ProductGrid extends ConsumerWidget {
  final List<Jewellery> jewellery;
  final ScrollController? controller;
  final bool isLoadingMore;

  const ProductGrid({
    super.key,
    required this.jewellery,
    this.controller,
    required this.isLoadingMore,
  });

  static const double _rowSpacing = 20;
  static const double _horizontalPadding = 24;
  static const double _cardHeight = 352;

  void _onAddToCart(
    BuildContext context,
    WidgetRef ref, {
    required CustomerDetail customer,
    required String productCode,
    //required String designno,
  }) async {
    //final branch = ref.read(filterProvider).productBranch ?? '';
    final auth = ref.read(authProvider);
    final pjcode = auth.user?.pjcode ?? '';
    final storeState = ref.read(storeProvider);

    String branch = '';
    if (storeState.selectedStore?.nickName != null) {
      branch = storeState.selectedStore!.nickName!;
    }

    if (branch.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a store to add to cart')),
      );
      return;
    }

    // ✅ No (productCode) family key — plain provider
    await ref
        .read(addToCartProvider.notifier)
        .addToCart(
          productCode: productCode,
          branch: branch,
          customer: customer,
          //designno: designno,
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
          content: Text(result?.errorMessage ?? 'Failed to add to cart'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ScaleSize.aspectRatio;

    if (jewellery.isEmpty) {
      return const Center(child: Text("No products found"));
    }

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        controller: controller,
        child: Column(
          children: [
            /// 🔹 FIRST 3 ITEMS
            GridView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: _horizontalPadding * r,
                vertical: 6 * r,
              ),
              itemCount: jewellery.length.clamp(0, 3),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: _rowSpacing * r,
                mainAxisSpacing: _rowSpacing * r,
                mainAxisExtent: _cardHeight * r,
              ),
              itemBuilder: (context, index) {
                return _buildCard(context, ref, jewellery[index]);
              },
            ),

            /// spacing after first grid
            if (jewellery.length > 3) SizedBox(height: _rowSpacing * r),

            /// 🔹 4th (wide) + 5th (normal)
            if (jewellery.length >= 4)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _horizontalPadding * r,
                ),
                child: Row(
                  children: [
                    /// 4th item → index 3 (always safe here)
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: _cardHeight * r,
                        child: Padding(
                          padding: EdgeInsets.only(right: 5 * r),
                          child: _buildCard(
                            context,
                            ref,
                            jewellery[3],
                            isWide: true,
                          ),
                        ),
                      ),
                    ),

                    /// spacing only if 5th exists
                    if (jewellery.length >= 5) SizedBox(width: 48 * r),

                    /// 5th item → index 4 (guarded)
                    if (jewellery.length >= 5)
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: _cardHeight * r,
                          child: _buildCard(context, ref, jewellery[4]),
                        ),
                      ),
                  ],
                ),
              ),

            /// spacing after wide row
            if (jewellery.length > 5) SizedBox(height: _rowSpacing * r),

            /// 🔹 REMAINING ITEMS (index 5+)
            if (jewellery.length > 5)
              GridView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: _horizontalPadding * r,
                ),
                itemCount: jewellery.length - 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: _rowSpacing * r,
                  mainAxisSpacing: _rowSpacing * r,
                  mainAxisExtent: _cardHeight * r,
                ),
                itemBuilder: (context, index) {
                  return _buildCard(context, ref, jewellery[index + 5]);
                },
              ),

            /// loading indicator
            if (isLoadingMore)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24 * r),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    WidgetRef ref,
    Jewellery item, {
    bool isWide = false,
  }) {
    final tagText = getTagText(item);

    return ProductCard(
      isWide: isWide,
      image: item.imageUrl ?? '',
      //description: item.itemNumber ?? '', //item.description ?? '',
      description: item.description ?? '',
      price: item.price ?? 0,
      tagText: tagText,
      tagColor: getTagColor(tagText),
      isSoldOut: false,
      onAddToCart: () async {
        debugPrint("Add → ${item.itemNumber}");
        final customer = await showDialog<CustomerDetail>(
          context: context,
          barrierDismissible: true,
          builder: (_) => const ContinueCartPopup(),
        );
        if (customer == null) return;

        _onAddToCart(
          context,
          ref,
          customer: customer,
          productCode: item.itemNumber ?? '',
          //designno: item.designno ?? '',
        );
      },

      //onTryOn: () => debugPrint("Try → ${item.itemNumber}"),
      onTryOn: () {
        //debugPrint("Try → ${item.itemNumber}");
        // context.pushNamed(
        //   RoutePages.jewellerycustomize.routeName,
        //   queryParameters: {'code': item.itemNumber ?? ''},
        // );
        context.pushNamed(
          RoutePages.jewellerycustomize.routeName,
          extra: item.designno,
        );
      },
      onHaertTap: () => debugPrint("❤️ ${item.itemNumber}"),
    );
  }
}
