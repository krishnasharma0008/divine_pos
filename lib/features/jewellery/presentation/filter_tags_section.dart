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

    // 1) Build list of tag labels from FilterState
    final tags = <String>[];

    // if (filter.selectedCategory.isNotEmpty) {
    //   tags.add(filter.selectedCategory);
    // }
    for (final o in filter.selectedCategory) {
      tags.add(o);
    }
    // if (filter.selectedSubCategory.isNotEmpty) {
    //   tags.add(filter.selectedSubCategory);
    // }
    for (final o in filter.selectedSubCategory) {
      tags.add(o);
    }
    // if (filter.selectedGender != null) {
    //   tags.add(filter.selectedGender!);
    // }
    for (final o in filter.selectedGender) {
      tags.add(o);
    }
    // if (filter.selectedMetal != null) {
    //   tags.add(filter.selectedMetal!);
    // }
    for (final o in filter.selectedMetal) {
      tags.add(o);
    }
    // if (filter.selectedShape != null) {
    //   tags.add(filter.selectedShape!);
    // }
    for (final o in filter.selectedShape) {
      tags.add(o);
    }
    if (filter.colorStartLabel != filter.colorEndLabel) {
      tags.add('Color: ${filter.colorStartLabel}-${filter.colorEndLabel}');
    }
    if (filter.clarityStartLabel != filter.clarityEndLabel) {
      tags.add(
        'Clarity: ${filter.clarityStartLabel}-${filter.clarityEndLabel}',
      );
    }
    if (filter.caratStartLabel != filter.caratEndLabel) {
      tags.add('Carat: ${filter.caratStartLabel}-${filter.caratEndLabel}');
    }
    for (final o in filter.selectedOccasions) {
      tags.add(o);
    }

    if (tags.isEmpty) return const SizedBox.shrink();

    return FilterTagsRow(
      selectedFilters: tags,
      onClearAll: () => notifier.resetFilters(),
      onRemoveTag: (tag) {
        // 2) Map tag back to filter and clear it
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
        } else if (tag.startsWith('Color:')) {
          notifier.setColorRange('D', 'J'); // or your default
        } else if (tag.startsWith('Clarity:')) {
          notifier.setClarityRange('IF', 'SI2'); // default
        } else if (tag.startsWith('Carat:')) {
          notifier.setCaratRange('0.10', '2.00'); // default
        }
      },
    );
  }
}
