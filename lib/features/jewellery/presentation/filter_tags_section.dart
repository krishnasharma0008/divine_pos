import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/filter_provider.dart';
import 'widget/filter_tags_row.dart';

class FilterTagsSection extends ConsumerWidget {
  const FilterTagsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final notifier = ref.read(filterProvider.notifier);

    final tags = <String>[];

    // Multi-select sets
    for (final o in filter.selectedCategory) tags.add(o);
    for (final o in filter.selectedSubCategory) tags.add(o);
    for (final o in filter.selectedGender) tags.add(o);
    for (final o in filter.selectedMetal) tags.add(o);
    for (final o in filter.selectedShape) tags.add(o);
    for (final o in filter.selectedOccasions) tags.add(o);

    // Price range
    if (filter.selectedPriceRange.start != 10000 ||
        filter.selectedPriceRange.end != 1000000) {
      tags.add(
        'Price: ₹${filter.selectedPriceRange.start.toInt()} - ₹${filter.selectedPriceRange.end.toInt()}',
      );
    }

    // // Color range
    // if (filter.colorStartLabel != filter.colorEndLabel) {
    //   tags.add('Color: ${filter.colorStartLabel}-${filter.colorEndLabel}');
    // }

    // // Clarity range
    // if (filter.clarityStartLabel != filter.clarityEndLabel) {
    //   tags.add(
    //     'Clarity: ${filter.clarityStartLabel}-${filter.clarityEndLabel}',
    //   );
    // }

    // Carat range
    if (filter.caratStartLabel != filter.caratEndLabel) {
      tags.add('Carat: ${filter.caratStartLabel}-${filter.caratEndLabel}');
    }

    if (tags.isEmpty) return const SizedBox.shrink();

    return FilterTagsRow(
      selectedFilters: tags,
      onClearAll: () => notifier.resetFilters(),
      onRemoveTag: (tag) {
        // Map tag back to filter and clear it
        if (filter.selectedCategory.contains(tag)) {
          notifier.toggleCategory(tag);
        } else if (filter.selectedSubCategory.contains(tag)) {
          notifier.toggleSubCategory(tag);
        } else if (filter.selectedGender.contains(tag)) {
          notifier.toggleGender(tag);
        } else if (filter.selectedMetal.contains(tag)) {
          notifier.toggleMetal(tag);
        } else if (filter.selectedShape.contains(tag)) {
          notifier.toggleShape(tag);
        } else if (filter.selectedOccasions.contains(tag)) {
          notifier.toggleOccasion(tag);
        } else if (tag.startsWith('Price:')) {
          notifier.setPrice(const RangeValues(10000, 1000000));
        } else
        //  if (tag.startsWith('Color:')) {
        //   notifier.setColorRange('D', 'J');
        // } else if (tag.startsWith('Clarity:')) {
        //   notifier.setClarityRange('IF', 'SI2');
        // } else
        if (tag.startsWith('Carat:')) {
          notifier.setCaratRange('0.10', '2.00');
        }
      },
    );
  }
}
