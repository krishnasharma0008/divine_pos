import 'dart:io';

//import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../shared/utils/api_endpointen.dart';
import '../../../shared/utils/http_client.dart';
import 'filter_provider.dart';
import 'jewellery_model.dart';

/// ✅ PROVIDER
final jewelleryProvider =
    StateNotifierProvider<JewelleryNotifier, SJewelleryState>((ref) {
      return JewelleryNotifier(ref);
    });

/// ✅ NOTIFIER
class JewelleryNotifier extends StateNotifier<SJewelleryState> {
  final Ref ref;
  JewelleryNotifier(this.ref) : super(SJewelleryState());

  /// Fetch jewellery list from API using current filters
  Future<bool> getJewelleryListing() async {
    state = state.copyWith(isLoading: true, error: null, errorMessage: null);

    try {
      final dio = ref.read(httpClientProvider);

      // 1️⃣ Get current filters
      final filter = ref.read(filterProvider);

      // 2️⃣ Build POST payload with all filters
      final postData = {
        "category": filter.selectedCategory.toList(),
        "sub_category": filter.selectedSubCategory.toList(),
        "gender": filter.selectedGender.toList(),
        "metal": filter.selectedMetal.toList(),
        "shape": filter.selectedShape.toList(),
        "occasion": filter.selectedOccasions.toList(),
        "color_start": filter.colorStartLabel,
        "color_end": filter.colorEndLabel,
        "clarity_start": filter.clarityStartLabel,
        "clarity_end": filter.clarityEndLabel,
        "carat_start": filter.caratStartLabel,
        "carat_end": filter.caratEndLabel,
        "price_start": filter.selectedPriceRange.start,
        "price_end": filter.selectedPriceRange.end,
      };

      // 3️⃣ Make POST request
      final response = await dio.post(
        ApiEndPoint.get_jewellery_listing,
        data: postData,
      );

      if (response.statusCode == HttpStatus.ok) {
        final success = response.data["success"] ?? false;

        if (success) {
          final jewelleryJson = (response.data["data"] as List<dynamic>)
              .cast<Map<String, dynamic>>();

          final jewellery = jewelleryJson
              .map((json) => Jewellery.fromJson(json))
              .toList();

          state = state.copyWith(isLoading: false, jewellery: jewellery);
          return true;
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: "No jewellery found",
          );
          return false;
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.data["msg"] ?? "Server Error",
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e,
        errorMessage: "Something went wrong. Please try again.",
      );
      return false;
    }
  }
}

/// ✅ STATE MODEL
class SJewelleryState {
  final bool isLoading;
  final List<Jewellery> jewellery;
  final Object? error;
  final String? errorMessage;

  SJewelleryState({
    this.isLoading = false,
    this.jewellery = const [],
    this.error,
    this.errorMessage,
  });

  SJewelleryState copyWith({
    bool? isLoading,
    List<Jewellery>? jewellery,
    Object? error,
    String? errorMessage,
  }) {
    return SJewelleryState(
      isLoading: isLoading ?? this.isLoading,
      jewellery: jewellery ?? this.jewellery,
      error: error,
      errorMessage: errorMessage,
    );
  }
}
