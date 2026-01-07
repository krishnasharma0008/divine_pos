import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/filter_provider.dart';
import '../data/category_item.dart';
//import 'category_row.dart';
import 'widget/category_row.dart';

class CategorySection extends ConsumerWidget {
  CategorySection({super.key});

  final categories = <CategoryItem>[
    CategoryItem(
      image: 'assets/jewellery/filter_tags/rings.jpg',
      label: 'Ring',
    ),
    CategoryItem(
      image: 'assets/jewellery/filter_tags/earrings.png',
      label: 'Earring',
    ),
    CategoryItem(
      image: 'assets/jewellery/filter_tags/pendant.png',
      label: 'Pendant',
    ),
    CategoryItem(
      image: 'assets/jewellery/filter_tags/mangalsutra.jpg',
      label: 'Mangalsutra',
    ),
    CategoryItem(
      image: 'assets/jewellery/filter_tags/solitaires.png',
      label: 'Solitaires',
    ),
    CategoryItem(
      image: 'assets/jewellery/filter_tags/bangles.jpg',
      label: 'Bangles',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final notifier = ref.read(filterProvider.notifier);

    final categories = <CategoryItem>[
      CategoryItem(
        image: 'assets/jewellery/filter_tags/rings.jpg',
        label: 'Ring',
      ),
      CategoryItem(
        image: 'assets/jewellery/filter_tags/earrings.png',
        label: 'Earring',
      ),
      CategoryItem(
        image: 'assets/jewellery/filter_tags/pendant.png',
        label: 'Pendant',
      ),
      CategoryItem(
        image: 'assets/jewellery/filter_tags/mangalsutra.jpg',
        label: 'Mangalsutra',
      ),
      CategoryItem(
        image: 'assets/jewellery/filter_tags/solitaires.png',
        label: 'Solitaires',
      ),
      CategoryItem(
        image: 'assets/jewellery/filter_tags/bangles.jpg',
        label: 'Bangles',
      ),
    ];

    final selectedIndexes = categories
        .asMap()
        .entries
        .where((e) => filter.selectedCategory.contains(e.value.label))
        .map((e) => e.key)
        .toList();

    return Container(
      color: Colors.white, // ✅ background color added
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 15,
      ), // optional spacing
      child: CategoryRow(
        items: categories,
        selectedIndexes: selectedIndexes,
        onSelect: (index) {
          notifier.toggleCategory(categories[index].label);
        },
      ),
    );
  }
}

//     return CategoryRow(
//       items: categories,
//       selectedIndexes: selectedIndexes,

//       onSelect: (index) {
//         notifier.toggleCategory(categories[index].label);
//       },
//     );
//   }
// }
