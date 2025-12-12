import 'package:flutter/material.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const ProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // First 3 cards in 3-column grid
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 31),
            
            itemCount: 3.clamp(0, products.length),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              mainAxisExtent: 399,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                isWide: false,
                image: product["image"],
                title: product["title"],
                price: product["price"],
                tagText: product["tagText"],
                tagColor: product["tagColor"],
                isSoldOut: product["soldOut"],
                onAddToCart: () => print("1"),
                onTryOn: () => print("2"),
              );
            },
          ),

          // 4th card (2/3 width) + 5th card (1/3 width) with fixed heights
          if (products.length > 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 31),
              child: Row(
                children: [
                  // 4th card - 2/3 width, fixed height
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 399,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ProductCard(
                          isWide: true,
                          image: products[3]["image"],
                          title: products[3]["title"],
                          price: products[3]["price"],
                          tagText: products[3]["tagText"],
                          tagColor: products[3]["tagColor"],
                          isSoldOut: products[3]["soldOut"],
                          onAddToCart: () => print("1"),
                          onTryOn: () => print("2"),
                        ),
                      ),
                    ),
                  ),
                  // 5th card - 1/3 width, fixed height
                  if (products.length > 4)
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 399,
                        child: ProductCard(
                          isWide: false,
                          image: products[4]["image"],
                          title: products[4]["title"],
                          price: products[4]["price"],
                          tagText: products[4]["tagText"],
                          tagColor: products[4]["tagColor"],
                          isSoldOut: products[4]["soldOut"],
                          onAddToCart: () => print("1"),
                          onTryOn: () => print("2"),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Remaining cards in 3-column grid
          if (products.length > 5)
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 31),
              itemCount: products.length - 5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                mainAxisExtent: 399,
              ),
              itemBuilder: (context, index) {
                final product = products[5 + index];
                return ProductCard(
                  isWide: false,
                  image: product["image"],
                  title: product["title"],
                  price: product["price"],
                  tagText: product["tagText"],
                  tagColor: product["tagColor"],
                  isSoldOut: product["soldOut"],
                  onAddToCart: () => print("1"),
                  onTryOn: () => print("2"),
                );
              },
            ),
        ],
      ),
    );
  }
}
