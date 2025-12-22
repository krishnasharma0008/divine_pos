import 'package:flutter/material.dart';
import 'product_card.dart';
import '../data/jewellery_model.dart';
import '../../../shared/utils/jewellery_helpers.dart';

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

  @override
  Widget build(BuildContext context) {
    if (jewellery.isEmpty) {
      return const Center(child: Text("No products found"));
    }

    return SingleChildScrollView(
      controller: controller, // ✅ THIS IS REQUIRED
      child: Column(
        children: [
          /// 🔹 FIRST 3 ITEMS → 3 COLUMN GRID
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: jewellery.length.clamp(0, 3),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              mainAxisExtent: 399,
            ),
            itemBuilder: (context, index) {
              final item = jewellery[index];
              final tagText = getTagText(item);

              return ProductCard(
                isWide: false,
                image: item.imageUrl ?? '',
                title: item.bomVariantName ?? '',
                price: formatWeight(item.weight),
                tagText: tagText,
                tagColor: getTagColor(tagText),
                isSoldOut: false,
                onAddToCart: () => debugPrint("Add → ${item.itemNumber}"),
                onTryOn: () => debugPrint("Try → ${item.itemNumber}"),
                onHaertTap: () => debugPrint("❤️ ${item.itemNumber}"),
              );
            },
          ),

          /// 🔹 4th (WIDE) + 5th (NORMAL)
          if (jewellery.length > 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 31),
              child: Row(
                children: [
                  /// 4th → WIDE (2/3)
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 399,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _buildCard(jewellery[3], isWide: true),
                      ),
                    ),
                  ),

                  /// 5th → NORMAL (1/3)
                  if (jewellery.length > 4)
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 399,
                        child: _buildCard(jewellery[4]),
                      ),
                    ),
                ],
              ),
            ),

          /// 🔹 REMAINING ITEMS → 3 COLUMN GRID
          if (jewellery.length > 5)
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 31),
              itemCount: jewellery.length - 5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                mainAxisExtent: 399,
              ),
              itemBuilder: (context, index) {
                final item = jewellery[index + 5];
                return _buildCard(item);
              },
            ),

          /// 🔹 LOAD MORE INDICATOR (IMPORTANT)
          if (isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  /// 🔹 Reusable card builder
  Widget _buildCard(Jewellery item, {bool isWide = false}) {
    final tagText = getTagText(item);

    return ProductCard(
      isWide: isWide,
      image: item.imageUrl ?? '',
      title: item.bomVariantName ?? '',
      price: formatWeight(item.weight), //item.weight,
      tagText: tagText,
      tagColor: getTagColor(tagText),
      isSoldOut: false,
      onAddToCart: () => debugPrint("Add → ${item.itemNumber}"),
      onTryOn: () => debugPrint("Try → ${item.itemNumber}"),
      onHaertTap: () => debugPrint("❤️ ${item.itemNumber}"),
    );
  }
}
