import 'package:divine_pos/features/jewellery/data/add_to_cart_notifier.dart';
import 'package:divine_pos/features/jewellery/presentation/product_card.dart';
import 'package:divine_pos/features/jewellery/data/jewellery_model.dart';
import 'package:divine_pos/features/cart/data/customer_detail_model.dart';
import 'package:divine_pos/features/jewellery_customize/presentation/widget/continue_cart_popup.dart';
import 'package:divine_pos/shared/routes/route_pages.dart';
import 'package:divine_pos/shared/utils/jewellery_helpers.dart';
import 'package:divine_pos/shared/utils/scale_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  static const double _gridSpacing = 20;
  static const double _horizontalPadding = 24;
  static const double _cardHeight = 352;
  static const double _topPadding = 6;
  static const double _wideGap = 48;
  static const double _wideRightInset = 5;
  static const int _topGridCount = 3;
  static const int _featuredStartIndex = 3;
  static const int _tailStartIndex = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ScaleSize.aspectRatio;

    if (jewellery.isEmpty) {
      return const Center(child: Text('No products found'));
    }

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        controller: controller,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopGrid(context, ref, r),
            if (jewellery.length > _topGridCount)
              SizedBox(height: _gridSpacing * r),
            if (jewellery.length >= 4) _buildFeaturedRow(context, ref, r),
            if (jewellery.length > _tailStartIndex)
              SizedBox(height: _gridSpacing * r),
            if (jewellery.length > _tailStartIndex)
              _buildRemainingGrid(context, ref, r),
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

  Widget _buildTopGrid(BuildContext context, WidgetRef ref, double r) {
    final items = jewellery.take(_topGridCount).toList();

    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: _horizontalPadding * r,
        vertical: _topPadding * r,
      ),
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: _gridSpacing * r,
        mainAxisSpacing: _gridSpacing * r,
        mainAxisExtent: _cardHeight * r,
      ),
      itemBuilder: (_, index) => _buildCard(context, ref, items[index]),
    );
  }

  Widget _buildFeaturedRow(BuildContext context, WidgetRef ref, double r) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _horizontalPadding * r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(
              height: _cardHeight * r,
              child: Padding(
                padding: EdgeInsets.only(right: _wideRightInset * r),
                child: _buildCard(
                  context,
                  ref,
                  jewellery[_featuredStartIndex],
                  isWide: true,
                ),
              ),
            ),
          ),
          if (jewellery.length >= 5) SizedBox(width: _wideGap * r),
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
    );
  }

  Widget _buildRemainingGrid(BuildContext context, WidgetRef ref, double r) {
    final items = jewellery.skip(_tailStartIndex).toList();

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: _horizontalPadding * r),
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: _gridSpacing * r,
        mainAxisSpacing: _gridSpacing * r,
        mainAxisExtent: _cardHeight * r,
      ),
      itemBuilder: (_, index) => _buildCard(context, ref, items[index]),
    );
  }

  Future<void> _onAddToCart(
    BuildContext context,
    WidgetRef ref, {
    required CustomerDetail customer,
    required String productCode,
    required String customercode,
    required String customername,
    required String branch,
    required int customerid,
  }) async {
    await ref
        .read(addToCartProvider.notifier)
        .addToCart(
          productCode: productCode,
          customerid: customerid,
          customercode: customercode,
          customername: customername,
          branch: branch,
          customerOrder: customer,
        );

    if (!context.mounted) return;

    final result = ref.read(addToCartProvider).value;

    if (result?.isSuccess == true) {
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
      description: item.itemNumber ?? '',
      price: item.price ?? 0,
      tagText: tagText,
      tagColor: getTagColor(tagText),
      isSoldOut: false,
      onAddToCart: () async {
        final customer = await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => ContinueCartPopup(parentContext: context),
        );

        if (customer == null) return;

        await _onAddToCart(
          context,
          ref,
          customer: customer,
          productCode: item.itemNumber ?? '',
          customercode: item.layingWith ?? '',
          customername: item.lying_with_name ?? '',
          branch: item.lying_with_nickname ?? '',
          customerid: item.lying_with_id ?? 0,
        );
      },
      onTryOn: () {
        GoRouter.of(context).pushNamed(
          RoutePages.jewellerycustomize.routeName,
          extra: {
            'customercode': item.layingWith,
            'customername': item.lying_with_name,
            'branch': item.lying_with_nickname,
            'customerid': item.lying_with_id,
            'productCode': item.itemNumber,
          },
        );
      },
      onHaertTap: () => debugPrint('❤️ ${item.itemNumber}'),
    );
  }
}
