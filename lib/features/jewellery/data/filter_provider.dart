import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'filter_state.dart';

/// Notifier that holds all jewellery filters.
class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier()
    : super(
        FilterState(
          selectedGender: const {},
          selectedPriceRange: const RangeValues(10000, 1000000),
          // selectstartprice:"10000",
          // selectebdprice:"1000000",
          selectedCategory: const {},
          selectedSubCategory: const {},
          colorStartLabel: 'D',
          colorEndLabel: 'J',
          clarityStartLabel: 'IF',
          clarityEndLabel: 'SI2',
          caratStartLabel: '0.10',
          caratEndLabel: '2.00',
          selectedShape: const {},
          selectedMetal: const {},
          selectedOccasions: const {},
        ),
      );

  // ---------------- GENDER ----------------
  // void setGender(String? gender) {
  //   state = state.copyWith(selectedGender: gender);
  // }

  void toggleGender(String value) {
    final current = {...state.selectedGender};
    if (current.contains(value)) {
      current.remove(value);
    } else {
      current.add(value);
    }
    state = state.copyWith(selectedGender: current);
  }

  // ---------------- PRICE RANGE ----------------
  void setPrice(RangeValues values) {
    state = state.copyWith(selectedPriceRange: values);
  }

  // ---------------- CATEGORY ----------------
  // void setCategory(String cat) {
  //   state = state.copyWith(selectedCategory: cat);
  // }

  void toggleCategory(String value) {
    final current = {...state.selectedCategory};
    if (current.contains(value)) {
      current.remove(value);
    } else {
      current.add(value);
    }
    state = state.copyWith(selectedCategory: current);
  }

  // ---------------- SUB CATEGORY ----------------
  // void setSubCategory(String subCat) {
  //   state = state.copyWith(selectedSubCategory: subCat);
  // }
  void toggleSubCategory(String value) {
    final current = {...state.selectedSubCategory};
    if (current.contains(value)) {
      current.remove(value);
    } else {
      current.add(value);
    }
    state = state.copyWith(selectedSubCategory: current);
  }

  // ---------------- COLOR ----------------
  void setColorRange(String start, String end) {
    state = state.copyWith(colorStartLabel: start, colorEndLabel: end);
  }

  // ---------------- CLARITY ----------------
  void setClarityRange(String start, String end) {
    state = state.copyWith(clarityStartLabel: start, clarityEndLabel: end);
  }

  // ---------------- CARAT ----------------
  void setCaratRange(String start, String end) {
    state = state.copyWith(caratStartLabel: start, caratEndLabel: end);
  }

  // ---------------- SHAPE ----------------
  // void setShape(String? shape) {
  //   state = state.copyWith(selectedShape: shape);
  // }

  void toggleShape(String value) {
    final current = {...state.selectedShape};
    if (current.contains(value)) {
      current.remove(value);
    } else {
      current.add(value);
    }
    state = state.copyWith(selectedShape: current);
  }

  // ---------------- METAL ----------------
  // void setMetal(String? metal) {
  //   state = state.copyWith(selectedMetal: metal);
  // }

  void toggleMetal(String value) {
    final current = {...state.selectedMetal};
    if (current.contains(value)) {
      current.remove(value);
    } else {
      current.add(value);
    }
    state = state.copyWith(selectedMetal: current);
  }

  // ---------------- OCCASION (MULTI) ----------------
  void toggleOccasion(String value) {
    final current = {...state.selectedOccasions};
    if (current.contains(value)) {
      current.remove(value);
    } else {
      current.add(value);
    }
    state = state.copyWith(selectedOccasions: current);
  }

  // ---------------- RESET ALL ----------------
  void resetFilters() {
    state = FilterState(
      selectedGender: const {},
      selectedPriceRange: const RangeValues(10000, 1000000),
      selectedCategory: const {},
      selectedSubCategory: const {},
      colorStartLabel: 'D',
      colorEndLabel: 'J',
      clarityStartLabel: 'IF',
      clarityEndLabel: 'SI2',
      caratStartLabel: '0.10',
      caratEndLabel: '2.00',
      selectedShape: const {},
      selectedMetal: const {},
      selectedOccasions: const {},
    );
  }
}

/// Global provider for filters.
final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((
  ref,
) {
  return FilterNotifier();
});
