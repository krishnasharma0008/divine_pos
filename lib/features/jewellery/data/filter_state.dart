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

  // Top button filters
  final bool isInStore;
  final String? productBranch;
  final bool allDesigns;
  final String? sortBy;
  final String? itemno;
  final int allStore;

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
    this.isInStore = true,
    this.productBranch,
    this.allDesigns = false,
    this.sortBy,
    this.itemno,
    this.allStore = 0,
  });

  FilterState copyWith({
    Set<String>? selectedGender,
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
    bool? isInStore,
    Nullable<String>? productBranch,
    bool? allDesigns,
    String? sortBy,
    Nullable<String>? itemno,
    int? allStore,
  }) {
    return FilterState(
      selectedGender: selectedGender ?? this.selectedGender,
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
      clarityStartLabel: clarityStartLabel != null
          ? clarityStartLabel.value
          : this.clarityStartLabel,
      clarityEndLabel: clarityEndLabel != null
          ? clarityEndLabel.value
          : this.clarityEndLabel,
      caratStartLabel: caratStartLabel != null
          ? caratStartLabel.value
          : this.caratStartLabel,
      caratEndLabel: caratEndLabel != null
          ? caratEndLabel.value
          : this.caratEndLabel,
      selectedShape: selectedShape ?? this.selectedShape,
      selectedMetalPurity: selectedMetalPurity ?? this.selectedMetalPurity,
      selectedMetalColor: selectedMetalColor ?? this.selectedMetalColor,
      selectedOccasions: selectedOccasions ?? this.selectedOccasions,
      isInStore: isInStore ?? this.isInStore,
      productBranch: productBranch != null
          ? productBranch.value
          : this.productBranch,
      allDesigns: allDesigns ?? this.allDesigns,
      sortBy: sortBy ?? this.sortBy,
      itemno: itemno != null ? itemno.value : this.itemno,
      allStore: allStore ?? this.allStore,
    );
  }
}

class Nullable<T> {
  final T? value;
  const Nullable(this.value);
}
