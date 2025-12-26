import 'package:flutter/material.dart';
import 'product_card.dart';
import '../data/jewellery_model.dart';
import '../../../shared/utils/jewellery_helpers.dart';
import '../../../shared/utils/scale_size.dart';
import '../../../shared/utils/currency_formatter.dart';

class ProductGrid extends StatelessWidget {
  final List<Jewellery> jewellery;
  final ScrollController? controller;
  final bool isLoadingMore;

  const ProductGrid({
    super.key,
    required this.jewellery,
    this.controller,
    required this.isLoadingMore,
  });

  static const double _rowSpacing = 50;
  static const double _horizontalPadding = 24;
  static const double _cardHeight = 424;

  @override
  Widget build(BuildContext context) {
    final r = ScaleSize.aspectRatio;

    if (jewellery.isEmpty) {
      return const Center(child: Text("No products found"));
    }

    return Container(
      color: Colors.white, // ✅ background color added
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
                return _buildCard(jewellery[index]);
              },
            ),

            if (jewellery.length > 3) SizedBox(height: _rowSpacing * r),

            /// 🔹 4th + 5th
            if (jewellery.length > 3)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _horizontalPadding * r,
                ),

                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: _cardHeight * r,
                        child: Padding(
                          padding: EdgeInsets.only(right: 5 * r),
                          child: _buildCard(jewellery[3], isWide: true),
                        ),
                      ),
                    ),
                    if (jewellery.length > 4)
                      SizedBox(
                        width: 48 * r,
                      ), // adjust value as needed space between column
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: _cardHeight * r,
                        child: _buildCard(jewellery[4]),
                      ),
                    ),
                  ],
                ),
              ),

            if (jewellery.length > 5) SizedBox(height: _rowSpacing * r),

            /// 🔹 REMAINING ITEMS
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
                  return _buildCard(jewellery[index + 5]);
                },
              ),

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

  Widget _buildCard(Jewellery item, {bool isWide = false}) {
    final tagText = getTagText(item);

    return ProductCard(
      isWide: isWide,
      image: item.imageUrl ?? '',
      description: item.description ?? '',
      price: item.price ?? 0,
      tagText: tagText,
      tagColor: getTagColor(tagText),
      isSoldOut: false,
      onAddToCart: () => debugPrint("Add → ${item.itemNumber}"),
      onTryOn: () => debugPrint("Try → ${item.itemNumber}"),
      onHaertTap: () => debugPrint("❤️ ${item.itemNumber}"),
    );
  }
}
