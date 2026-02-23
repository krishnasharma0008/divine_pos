import 'package:flutter/material.dart';

class FilterState {
  final Set<String> selectedGender;
  final RangeValues? selectedPriceRange;
  final Set<String> selectedCategory;
  final Set<String> selectedSubCategory;
  final String? colorStartLabel;
  final String? colorEndLabel;
  final String? clarityStartLabel;
  final String? clarityEndLabel;
  final String? caratStartLabel;
  final String? caratEndLabel;
  final Set<String> selectedShape;
  final Set<String> selectedMetalPurity;
  final Set<String> selectedMetalColor;
  final Set<String> selectedOccasions;
  // final Set<String> ColorStartLabel;
  // final Set<String> ColorEndLabel;
  // final Set<String> ClaritieStartLabel;
  // final Set<String> ClaritieEndLabel;

  final bool isInStore;
  final String? productBranch;
  final bool allDesigns;
  final String? sortBy;

  const FilterState({
    required this.selectedGender,
    this.selectedPriceRange,
    required this.selectedCategory,
    required this.selectedSubCategory,
    this.colorStartLabel,
    this.colorEndLabel,
    this.clarityStartLabel,
    this.clarityEndLabel,
    this.caratStartLabel,
    this.caratEndLabel,
    required this.selectedShape,
    required this.selectedMetalPurity,
    required this.selectedMetalColor,
    required this.selectedOccasions,
    // required this.selectedColors,
    // required this.selectedClarities,

    // top button filters
    this.isInStore = true, // ✅ default in-store
    this.productBranch, // null = no branch filter
    this.allDesigns = false,
    this.sortBy,
  });

  get selectedClarity => null;

  FilterState copyWith({
    Set<String>? selectedGender,
    //RangeValues? selectedPriceRange,
    Nullable<RangeValues>? selectedPriceRange,
    Set<String>? selectedCategory,
    Set<String>? selectedSubCategory,
    Nullable<String>? colorStartLabel,
    Nullable<String>? colorEndLabel,
    Nullable<String>? clarityStartLabel,
    Nullable<String>? clarityEndLabel,
    Nullable<String>? caratStartLabel,
    Nullable<String>? caratEndLabel,
    Set<String>? selectedShape,
    Set<String>? selectedMetalPurity,
    Set<String>? selectedMetalColor,
    Set<String>? selectedOccasions,
    Set<String>? selectedColors,
    Set<String>? selectedClarities,
    //top button filters
    bool? isInStore,
    //String? productBranch,
    Nullable<String>? productBranch, // 🔥 IMPORTANT
    bool? allDesigns,
    String? sortBy,
  }) {
    return FilterState(
      selectedGender: selectedGender ?? this.selectedGender,
      //selectedPriceRange: selectedPriceRange ?? this.selectedPriceRange,
      selectedPriceRange: selectedPriceRange != null
          ? selectedPriceRange.value
          : this.selectedPriceRange,

      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedSubCategory: selectedSubCategory ?? this.selectedSubCategory,

      colorStartLabel: colorStartLabel != null
          ? colorStartLabel.value
          : this.colorStartLabel,
      colorEndLabel: colorEndLabel != null
          ? colorEndLabel.value
          : this.colorEndLabel,
      //colorStartLabel: colorStartLabel ?? this.colorStartLabel,
      //colorEndLabel: colorEndLabel ?? this.colorEndLabel,
      clarityStartLabel: clarityStartLabel != null
          ? clarityStartLabel.value
          : this.clarityStartLabel,
      clarityEndLabel: clarityEndLabel != null
          ? clarityEndLabel.value
          : this.clarityEndLabel,
      // clarityStartLabel: clarityStartLabel ?? this.clarityStartLabel,
      // clarityEndLabel: clarityEndLabel ?? this.clarityEndLabel,
      //caratStartLabel: caratStartLabel ?? this.caratStartLabel,
      caratStartLabel: caratStartLabel != null
          ? caratStartLabel.value
          : this.caratStartLabel,
      caratEndLabel: caratEndLabel != null
          ? caratEndLabel.value
          : this.caratEndLabel,
      //caratEndLabel: caratEndLabel ?? this.caratEndLabel,
      selectedShape: selectedShape ?? this.selectedShape,
      selectedMetalPurity: selectedMetalPurity ?? this.selectedMetalPurity,
      selectedMetalColor: selectedMetalColor ?? this.selectedMetalColor,
      selectedOccasions: selectedOccasions ?? this.selectedOccasions,
      // selectedColors: selectedColors ?? this.selectedColors,
      // selectedClarities: selectedClarities ?? this.selectedClarities,

      //top button filters
      isInStore: isInStore ?? this.isInStore,
      //productBranch: productBranch ?? this.productBranch, // ✅ fixed
      productBranch: productBranch != null
          ? productBranch.value
          : this.productBranch,
      allDesigns: allDesigns ?? this.allDesigns,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class Nullable<T> {
  final T? value;
  const Nullable(this.value);
}
