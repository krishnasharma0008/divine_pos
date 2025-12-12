import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/filter_provider.dart';
import '../data/category_item.dart';
//import 'category_row.dart';
import 'widget/category_row.dart';

class CategorySection extends ConsumerWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final notifier = ref.read(filterProvider.notifier);

    final categories = <CategoryItem>[
      CategoryItem(
        image: 'assets/jewellery/filter_tags/rings.jpg',
        label: 'Rings',
      ),
      CategoryItem(
        image: 'assets/jewellery/filter_tags/earrings.png',
        label: 'Earrings',
      ),
      CategoryItem(
        image: 'assets/jewellery/filter_tags/bangles.png',
        label: 'Bangles',
      ),
      CategoryItem(
        image: 'assets/jewellery/filter_tags/mangalsutra.png',
        label: 'Mangalsutra',
      ),
      CategoryItem(
        image: 'assets/jewellery/filter_tags/nosepin.png',
        label: 'Nosepin',
      ),
    ];

    final selectedIndexes = categories
        .asMap()
        .entries
        .where((e) => filter.selectedCategory.contains(e.value.label))
        .map((e) => e.key)
        .toList();

    return CategoryRow(
      items: categories,
      selectedIndexes: selectedIndexes,
      onSelect: (index) {
        notifier.toggleCategory(categories[index].label);
      },
    );
  }
}
