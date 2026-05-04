import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'filter_state.dart';

class FilterNotifier extends Notifier<FilterState> {
  @override
  FilterState build() {
    return const FilterState(
      selectedGender: {},
      selectedPriceRange: null, // RangeValues(10000, 1000000),
      selectedCategory: {},
      selectedSubCategory: {},
      colorStartLabel: null, //'D',
      colorEndLabel: null, //'J',
      clarityStartLabel: null, //'IF',
      clarityEndLabel: null, //'SI2',
      caratStartLabel: null, // '0.10',
      caratEndLabel: null, // '2.99',
      selectedShape: {},
      selectedMetalPurity: {'18KT'},
      selectedMetalColor: {}, // {'Yellow'},
      selectedOccasions: {},
      itemno: null,
      initialized: false,
      // selectedColors: {},
      // selectedClarities: {},
    );
  }

  // ───────────────── Top buttons ─────────────────

  void setProductsInStore() {
    state = state.copyWith(
      isInStore: true,
      //productBranch: null,
      productBranch: const Nullable(null), // clear
      allDesigns: false,
      allStore: 1, // Set the allStore field to indicate this selection
    );
  }

  void setProductsAtOtherBranch(String branchCode) {
    state = state.copyWith(
      isInStore: false,
      //productBranch: branchCode,
      productBranch: Nullable(branchCode), // ✅ SET
      allDesigns: false,
      allStore: 1,
    );
  }

  void setAllDesigns() {
    state = state.copyWith(
      isInStore: false,
      //productBranch: null,
      productBranch: const Nullable(null), // ✅ now REALLY null
      allDesigns: true,
    );
  }

  void setAllStore() {
    state = state.copyWith(
      isInStore: true,
      //productBranch: null,
      productBranch: const Nullable(null), // clear
      allDesigns: false,
      allStore: 0, // Set the allStore field to indicate this selection
    );
  }

  void setSort(String? value) {
    state = state.copyWith(sortBy: value);
  }

  // ───────────────── Generic toggles ─────────────────

  void _toggleSet(
    Set<String> current,
    String value,
    void Function(Set<String>) update,
  ) {
    final updated = {...current};
    updated.contains(value) ? updated.remove(value) : updated.add(value);
    update(updated);
  }

  void toggleGender(String v) => _toggleSet(
    state.selectedGender,
    v,
    (s) => state = state.copyWith(selectedGender: s),
  );

  // void toggleCategory(String v) => _toggleSet(
  //   state.selectedCategory,
  //   v,
  //   (s) => state = state.copyWith(selectedCategory: s),
  // );

  void toggleCategory(String v) {
    final value = v.toLowerCase();

    //debugPrint('Toggling category: $v');

    // 1) Handle Solitaire specially
    if (value == 'solitaires') {
      final alreadySelected = state.selectedCategory.contains(v);
      if (alreadySelected) {
        // Turn off solitaire
        final next = {...state.selectedCategory}..remove(v);
        state = state.copyWith(selectedCategory: next);
      } else {
        // Turn on solitaire as single category + clear other filters
        state = state.copyWith(selectedCategory: {v});
        applySolitaireCategory();
      }
      return;
    }

    // 2) For any non‑solitaire category, remove solitaire if present
    var next = {...state.selectedCategory};
    next.removeWhere((c) => c.toLowerCase() == 'solitaires');

    // Then toggle the requested category
    if (next.contains(v)) {
      next.remove(v);
    } else {
      next.add(v);
    }

    state = state.copyWith(selectedCategory: next);
  }

  void toggleSubCategory(String v) => _toggleSet(
    state.selectedSubCategory,
    v,
    (s) => state = state.copyWith(selectedSubCategory: s),
  );

  void toggleShape(String v) => _toggleSet(
    state.selectedShape,
    v,
    (s) => state = state.copyWith(selectedShape: s),
  );

  void toggleMetalPurity(String v) => _toggleSet(
    state.selectedMetalPurity,
    v,
    (s) => state = state.copyWith(selectedMetalPurity: s),
  );

  void toggleMetalColor(String v) => _toggleSet(
    state.selectedMetalColor,
    v,
    (s) => state = state.copyWith(selectedMetalColor: s),
  );

  void toggleOccasion(String v) => _toggleSet(
    state.selectedOccasions,
    v,
    (s) => state = state.copyWith(selectedOccasions: s),
  );

  // ───────────────── Ranges ─────────────────

  void setPrice(RangeValues v) =>
      state = state.copyWith(selectedPriceRange: Nullable(v));

  void removePrice() =>
      state = state.copyWith(selectedPriceRange: const Nullable(null));

  // void setCaratRange(String s, String e) =>
  //     state = state.copyWith(caratStartLabel: s, caratEndLabel: e);

  void setCaratRange(String s, String e) => state = state.copyWith(
    caratStartLabel: Nullable(s),
    caratEndLabel: Nullable(e),
  );

  void removeCarat() => state = state.copyWith(
    caratStartLabel: const Nullable(null),
    caratEndLabel: const Nullable(null),
  );

  // void removeColor() =>
  //     state = state.copyWith(colorStartLabel: null, colorEndLabel: null);

  // void removeClarity() =>
  //     state = state.copyWith(clarityStartLabel: null, clarityEndLabel: null);

  // void setColorRange(String s, String e) =>
  //     state = state.copyWith(colorStartLabel: s, colorEndLabel: e);

  // void setClarityRange(String s, String e) =>
  //     state = state.copyWith(clarityStartLabel: s, clarityEndLabel: e);

  void setColorRange(String s, String e) => state = state.copyWith(
    colorStartLabel: Nullable(s),
    colorEndLabel: Nullable(e),
  );

  void removeColor() => state = state.copyWith(
    colorStartLabel: const Nullable(null),
    colorEndLabel: const Nullable(null),
  );

  void setClarityRange(String s, String e) => state = state.copyWith(
    clarityStartLabel: Nullable(s),
    clarityEndLabel: Nullable(e),
  );

  void removeClarity() => state = state.copyWith(
    clarityStartLabel: const Nullable(null),
    clarityEndLabel: const Nullable(null),
  );

  // void setCaratRange(String s, String e) =>
  //     state = state.copyWith(caratStartLabel: s, caratEndLabel: e);

  // ───────────────── Route setters (single select) ─────────────────

  void setCategory(String value) {
    state = state.copyWith(selectedCategory: {value});
    debugPrint('Selected Category : $value');
    // if (value.toLowerCase() == 'solitaire') {
    //   applySolitaireCategory();
    // } else {
    //   resetFilters();
    // }
  }

  void setSubCategory(String value) {
    state = state.copyWith(selectedSubCategory: {value});
  }

  void setItemno(String? itemno) {
    state = state.copyWith(itemno: Nullable(itemno)); // designno
  }

  void markInitialized() {
    state = state.copyWith(initialized: true);
  }

  // ───────────────── Reset ─────────────────
  void resetFilters() {
    state = state.copyWith(
      selectedGender: {},
      selectedPriceRange: const Nullable(null), // ✅
      selectedCategory: {},
      selectedSubCategory: {},
      colorStartLabel: const Nullable(null), // ✅
      colorEndLabel: const Nullable(null), // ✅
      clarityStartLabel: const Nullable(null), // ✅
      clarityEndLabel: const Nullable(null), // ✅
      caratStartLabel: const Nullable(null), // ✅
      caratEndLabel: const Nullable(null), // ✅
      selectedShape: {},
      selectedMetalPurity: {'18KT'},
      selectedMetalColor: {},
      selectedOccasions: {},
      itemno: const Nullable(null),
    );
  }

  // for solitaire
  void applySolitaireCategory() {
    state = state.copyWith(
      selectedGender: {},
      selectedPriceRange: null,
      selectedSubCategory: {},
      selectedShape: {},
      selectedMetalPurity: {},
      selectedMetalColor: {},
      selectedOccasions: {},

      // clear ranges
      colorStartLabel: null,
      colorEndLabel: null,
      clarityStartLabel: null,
      clarityEndLabel: null,
      caratStartLabel: null,
      caratEndLabel: null,
      // optional: clear sort / top buttons if you want
      sortBy: null,
      // isInStore, productBranch, allDesigns can stay as-is or also reset
      itemno: const Nullable(null), //
    );
  }
}

// ───────────────── Provider ─────────────────

final filterProvider =
    NotifierProvider.autoDispose<FilterNotifier, FilterState>(
      FilterNotifier.new,
    );
