import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'filter_state.dart';

class FilterNotifier extends Notifier<FilterState> {
  @override
  FilterState build() {
    return const FilterState(
      selectedGender: {},
      selectedPriceRange: RangeValues(10000, 1000000),
      selectedCategory: {},
      selectedSubCategory: {},
      colorStartLabel: 'D',
      colorEndLabel: 'J',
      clarityStartLabel: 'IF',
      clarityEndLabel: 'SI2',
      caratStartLabel: '0.10',
      caratEndLabel: '2.99',
      selectedShape: {},
      selectedMetal: {'18KT Yellow Gold'},
      selectedOccasions: {},
    );
  }

  // ───────────────── Top buttons ─────────────────

  void setProductsInStore() {
    state = state.copyWith(
      isInStore: true,
      productBranch: null,
      allDesigns: false,
    );
  }

  void setProductsAtOtherBranch(String branchCode) {
    state = state.copyWith(
      isInStore: false,
      productBranch: branchCode,
      allDesigns: false,
    );
  }

  void setAllDesigns() {
    state = state.copyWith(
      isInStore: false,
      productBranch: null,
      allDesigns: true,
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

  void toggleCategory(String v) => _toggleSet(
    state.selectedCategory,
    v,
    (s) => state = state.copyWith(selectedCategory: s),
  );

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

  void toggleMetal(String v) => _toggleSet(
    state.selectedMetal,
    v,
    (s) => state = state.copyWith(selectedMetal: s),
  );

  void toggleOccasion(String v) => _toggleSet(
    state.selectedOccasions,
    v,
    (s) => state = state.copyWith(selectedOccasions: s),
  );

  // ───────────────── Ranges ─────────────────

  void setPrice(RangeValues v) => state = state.copyWith(selectedPriceRange: v);

  void setColorRange(String s, String e) =>
      state = state.copyWith(colorStartLabel: s, colorEndLabel: e);

  void setClarityRange(String s, String e) =>
      state = state.copyWith(clarityStartLabel: s, clarityEndLabel: e);

  void setCaratRange(String s, String e) =>
      state = state.copyWith(caratStartLabel: s, caratEndLabel: e);

  // ───────────────── Route setters (single select) ─────────────────

  void setCategory(String value) {
    state = state.copyWith(selectedCategory: {value});
  }

  void setSubCategory(String value) {
    state = state.copyWith(selectedSubCategory: {value});
  }

  // ───────────────── Reset ─────────────────
  void resetFilters() {
    state = state.copyWith(
      selectedGender: {},
      selectedPriceRange: const RangeValues(10000, 1000000),
      selectedCategory: {},
      selectedSubCategory: {},
      colorStartLabel: 'D',
      colorEndLabel: 'J',
      clarityStartLabel: 'IF',
      clarityEndLabel: 'SI2',
      caratStartLabel: '0.10',
      caratEndLabel: '2.99',
      selectedShape: {},
      selectedMetal: {'18KT Yellow Gold'},
      selectedOccasions: {},
      // Top buttons remain untouched
    );
  }
}

// ───────────────── Provider ─────────────────

final filterProvider =
    NotifierProvider.autoDispose<FilterNotifier, FilterState>(
      FilterNotifier.new,
    );
