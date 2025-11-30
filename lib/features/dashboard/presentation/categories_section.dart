import 'package:flutter/material.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      ('Necklaces', 'assets/dashboard/categories/cat_necklaces.png'),
      ('Bangles', 'assets/dashboard/categories/cat_bangles.png'),
      ('Mangalsutra', 'assets/dashboard/categories/cat_mangalsutra.png'),
      ('Rings', 'assets/dashboard/categories/cat_rings.png'),
      ('Solitaire', 'assets/dashboard/categories/cat_solitaire.png'),
      ('Bracelet', 'assets/dashboard/categories/cat_bracelet.jpg'),
      ('Earrings', 'assets/dashboard/categories/cat_earrings.jpg'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const Text(
            'CATEGORIES',
            style: TextStyle(
              fontSize: 16,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Beautifully Organized. Brilliantly Designed.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            itemCount: categories.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 150,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final item = categories[index];
              return CategoryTile(label: item.$1, asset: item.$2);
            },
          ),
        ],
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String label;
  final String asset;

  const CategoryTile({super.key, required this.label, required this.asset});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(asset, fit: BoxFit.cover),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.black.withAlpha((0.35 * 255).round()),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
