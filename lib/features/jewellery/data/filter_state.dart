import 'package:flutter/material.dart';

class FilterState {
  final Set<String> selectedGender;
  final RangeValues selectedPriceRange;
  final Set<String> selectedCategory;
  final Set<String> selectedSubCategory;

  // NEW fields
  final String colorStartLabel;
  final String colorEndLabel;
  final String clarityStartLabel;
  final String clarityEndLabel;
  final String caratStartLabel;
  final String caratEndLabel;

  final Set<String> selectedShape;
  final Set<String> selectedMetal;
  final Set<String> selectedOccasions;

  FilterState({
    Set<String>? selectedGender,
    required this.selectedPriceRange,
    Set<String>? selectedCategory,
    Set<String>? selectedSubCategory,
    this.colorStartLabel = 'D',
    this.colorEndLabel = 'J',
    this.clarityStartLabel = 'IF',
    this.clarityEndLabel = 'SI2',
    this.caratStartLabel = '0.10',
    this.caratEndLabel = '2.00',
    Set<String>? selectedShape,
    Set<String>? selectedMetal,
    Set<String>? selectedOccasions,
  }) : selectedGender = selectedGender ?? const {},
       selectedCategory = selectedCategory ?? const {},
       selectedSubCategory = selectedSubCategory ?? const {},
       selectedShape = selectedShape ?? const {},
       selectedMetal = selectedMetal ?? const {},
       selectedOccasions = selectedOccasions ?? const {};

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
    );
  }
}
