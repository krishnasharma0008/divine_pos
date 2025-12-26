import 'package:flutter/material.dart';

class FilterState {
  final Set<String> selectedGender;
  final RangeValues selectedPriceRange;
  final Set<String> selectedCategory;
  final Set<String> selectedSubCategory;
  final String colorStartLabel;
  final String colorEndLabel;
  final String clarityStartLabel;
  final String clarityEndLabel;
  final String caratStartLabel;
  final String caratEndLabel;
  final Set<String> selectedShape;
  final Set<String> selectedMetal;
  final Set<String> selectedOccasions;

  final bool isInStore;
  final String? productBranch;
  final bool allDesigns;
  final String? sortBy;

  const FilterState({
    required this.selectedGender,
    required this.selectedPriceRange,
    required this.selectedCategory,
    required this.selectedSubCategory,
    required this.colorStartLabel,
    required this.colorEndLabel,
    required this.clarityStartLabel,
    required this.clarityEndLabel,
    required this.caratStartLabel,
    required this.caratEndLabel,
    required this.selectedShape,
    required this.selectedMetal,
    required this.selectedOccasions,

    // top button filters
    this.isInStore = true, // ✅ default in-store
    this.productBranch, // null = no branch filter
    this.allDesigns = false,
    this.sortBy,
  });

  FilterState copyWith({
    Set<String>? selectedGender,
    RangeValues? selectedPriceRange,
    Set<String>? selectedCategory,
    Set<String>? selectedSubCategory,
    String? colorStartLabel,
    String? colorEndLabel,
    String? clarityStartLabel,
    String? clarityEndLabel,
    String? caratStartLabel,
    String? caratEndLabel,
    Set<String>? selectedShape,
    Set<String>? selectedMetal,
    Set<String>? selectedOccasions,
    //top button filters
    bool? isInStore,
    String? productBranch,
    bool? allDesigns,
    String? sortBy,
  }) {
    return FilterState(
      selectedGender: selectedGender ?? this.selectedGender,
      selectedPriceRange: selectedPriceRange ?? this.selectedPriceRange,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedSubCategory: selectedSubCategory ?? this.selectedSubCategory,
      colorStartLabel: colorStartLabel ?? this.colorStartLabel,
      colorEndLabel: colorEndLabel ?? this.colorEndLabel,
      clarityStartLabel: clarityStartLabel ?? this.clarityStartLabel,
      clarityEndLabel: clarityEndLabel ?? this.clarityEndLabel,
      caratStartLabel: caratStartLabel ?? this.caratStartLabel,
      caratEndLabel: caratEndLabel ?? this.caratEndLabel,
      selectedShape: selectedShape ?? this.selectedShape,
      selectedMetal: selectedMetal ?? this.selectedMetal,
      selectedOccasions: selectedOccasions ?? this.selectedOccasions,

      //top button filters
      isInStore: isInStore ?? this.isInStore,
      productBranch: productBranch ?? this.productBranch, // ✅ fixed
      allDesigns: allDesigns ?? this.allDesigns,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
