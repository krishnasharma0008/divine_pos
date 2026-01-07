import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/filter_provider.dart';
import 'widget/filter_tags_row.dart';
import '../../../shared/utils/scale_size.dart';

// Map codes to labels for diamond shapes
const Map<String, String> diamondShapeLabels = {
  "RND": "Round",
  "PRN": "Princess",
  "OVL": "Oval",
  "PER": "Pear",
  "RADQ": "Radiant",
  "CUSQ": "Cushion",
  "HRT": "Heart",
};

// Same defaults used in FilterNotifier
// const RangeValues kDefaultPriceRange = RangeValues(10000, 1000000);
// const String kDefaultCaratStart = '0.10';
// const String kDefaultCaratEnd = '2.99';

class FilterTagsSection extends ConsumerWidget {
  const FilterTagsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final notifier = ref.read(filterProvider.notifier);
    final fem = ScaleSize.aspectRatio;

    final tags = <String>[];

    // Multi-select sets
    for (final o in filter.selectedCategory) {
      tags.add(o);
    }
    for (final o in filter.selectedSubCategory) {
      tags.add(o);
    }
    for (final o in filter.selectedGender) {
      tags.add(o);
    }
    for (final o in filter.selectedMetal) {
      tags.add(o);
    }

    // Map diamond shapes from code → label
    for (final o in filter.selectedShape) {
      tags.add(diamondShapeLabels[o] ?? o);
    }

    for (final o in filter.selectedOccasions) {
      tags.add(o);
    }

    // // Price range tag ONLY when changed from default
    // if (filter.selectedPriceRange != kDefaultPriceRange) {
    //   tags.add(
    //     'Price: ₹${filter.selectedPriceRange.start.toInt()} - ₹${filter.selectedPriceRange.end.toInt()}',
    //   );
    // }

    // Price tag — only if set
    if (filter.selectedPriceRange != null) {
      tags.add(
        'Price: ₹${filter.selectedPriceRange!.start.toInt()} - ₹${filter.selectedPriceRange!.end.toInt()}',
      );
    }

    // Carat tag — only if set
    if (filter.caratStartLabel != null && filter.caratEndLabel != null) {
      tags.add('Carat: ${filter.caratStartLabel}-${filter.caratEndLabel}');
    }

    // // Carat range tag ONLY when changed from default
    // if (filter.caratStartLabel != kDefaultCaratStart ||
    //     filter.caratEndLabel != kDefaultCaratEnd) {
    //   tags.add('Carat: ${filter.caratStartLabel}-${filter.caratEndLabel}');
    // }

    if (tags.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.only(right: fem * 15),
      //color: Colors.red,
      child: FilterTagsRow(
        selectedFilters: tags,
        onClearAll: () {
          notifier.resetFilters(); // Reset filter state
          // You can also trigger top buttons reset here if needed.
        },
        onRemoveTag: (tag) {
          // Map back label → code to remove from filter
          final shapeCode = diamondShapeLabels.entries
              .firstWhere(
                (e) => e.value == tag,
                orElse: () => const MapEntry('', ''),
              )
              .key;

          // Map tag back to filter and clear it
          if (filter.selectedCategory.contains(tag)) {
            notifier.toggleCategory(tag);
          } else if (filter.selectedSubCategory.contains(tag)) {
            notifier.toggleSubCategory(tag);
          } else if (filter.selectedGender.contains(tag)) {
            notifier.toggleGender(tag);
          } else if (filter.selectedMetal.contains(tag)) {
            notifier.toggleMetal(tag);
          } else if (shapeCode.isNotEmpty &&
              filter.selectedShape.contains(shapeCode)) {
            notifier.toggleShape(shapeCode);
          } else if (filter.selectedOccasions.contains(tag)) {
            notifier.toggleOccasion(tag);

            // Reset price only when the price tag is removed
          }
           else if (tag.startsWith('Price:')) {
            notifier.removePrice(); // ✅ use the nullable remove function
          } else if (tag.startsWith('Carat:')) {
            notifier.removeCarat(); // ✅ use the nullable remove function
          }
          //  else if (tag.startsWith('Price:')) {
          //   notifier.setPrice(kDefaultPriceRange);

          //   // Reset carat only when the carat tag is removed
          // } else if (tag.startsWith('Carat:')) {
          //   notifier.setCaratRange(kDefaultCaratStart, kDefaultCaratEnd);
          // }
        },
      ),
    );
  }
}
