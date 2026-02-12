import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../shared/utils/api_endpointen.dart';
import '../../../shared/utils/http_client.dart';
import 'store_details.dart';
import 'filter_model.dart';

/// STATE MODEL
class StoreDetailState {
  final bool isLoading;
  final List<StoreDetail> stores; // list of all stores
  final StoreDetail? selectedStore; // currently selected store
  /// ✅ Filters data (categories, subCategories, collections)
  final FilterModelState filters;
  final Object? error;
  final String? errorMessage;

  const StoreDetailState({
    this.isLoading = false,
    this.stores = const [],
    this.selectedStore,
    this.filters = const FilterModelState(),
    this.error,
    this.errorMessage,
  });

  StoreDetailState copyWith({
    bool? isLoading,
    List<StoreDetail>? stores,
    StoreDetail? selectedStore,
    FilterModelState? filters,
    Object? error,
    String? errorMessage,
  }) {
    return StoreDetailState(
      isLoading: isLoading ?? this.isLoading,
      stores: stores ?? this.stores,
      // only override selectedStore when a non-null value is passed
      selectedStore: selectedStore ?? this.selectedStore,
      filters: filters ?? this.filters,
      error: error,
      errorMessage: errorMessage,
    );
  }
}

/// PROVIDER
final storeProvider =
    StateNotifierProvider.autoDispose<StoreNotifier, StoreDetailState>((ref) {
      return StoreNotifier(ref);
    });

/// NOTIFIER
class StoreNotifier extends StateNotifier<StoreDetailState> {
  StoreNotifier(this.ref) : super(const StoreDetailState());

  final Ref ref;

  Future<bool> getPJStore({required String pjcode}) async {
    state = state.copyWith(isLoading: true, error: null, errorMessage: null);

    try {
      final dio = ref.read(httpClientProvider);
      final postData = {"code": pjcode};

      final response = await dio.post(ApiEndPoint.get_branch, data: postData);

      debugPrint('getPJStore response: ${response.data}');

      if (response.statusCode == HttpStatus.ok) {
        final success = response.data["success"] ?? false;

        if (success) {
          final storesJson = (response.data["data"] as List<dynamic>)
              .cast<Map<String, dynamic>>();

          final stores = storesJson
              .map((json) => StoreDetail.fromJson(json))
              .toList();

          state = state.copyWith(
            isLoading: false,
            stores: stores,
            selectedStore: stores.isNotEmpty ? stores.first : null,
            error: null,
            errorMessage: null,
          );
          return true;
        } else {
          state = state.copyWith(
            isLoading: false,
            stores: const [],
            selectedStore: null,
            errorMessage: response.data["msg"] ?? "Store not found",
          );
          return false;
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          stores: const [],
          selectedStore: null,
          errorMessage: response.data["msg"] ?? "Server error",
        );
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('getPJStore error: $e');
      debugPrintStack(stackTrace: stackTrace);

      state = state.copyWith(
        isLoading: false,
        stores: const [],
        selectedStore: null,
        error: e,
        errorMessage: "Store not found",
      );
      return false;
    }
  }

  /// ─────────────────────────────────────────────
  /// FETCH FILTERS
  /// ─────────────────────────────────────────────
  Future<bool> getFilters() async {
    state = state.copyWith(
      filters: state.filters.copyWith(
        isLoading: true,
        error: null,
        errorMessage: null,
      ),
    );

    try {
      final dio = ref.read(httpClientProvider);
      final response = await dio.get(ApiEndPoint.get_jewellery_filters);

      //debugPrint('getFilters response: ${response.data}');

      if (response.statusCode == HttpStatus.ok) {
        final success = response.data["success"] ?? false;

        if (success) {
          final data = response.data;

          state = state.copyWith(
            filters: state.filters.copyWith(
              isLoading: false,
              categories: List<String>.from(data["category"] ?? const []),
              subCategories: List<String>.from(
                data["sub_category"] ?? const [],
              ),
              collections: List<String>.from(data["collection"] ?? const []),
            ),
          );
          return true;
        }
      }

      state = state.copyWith(
        filters: state.filters.copyWith(
          isLoading: false,
          errorMessage: "Filters not found",
        ),
      );
      return false;
    } catch (e, st) {
      debugPrint('getFilters error: $e');
      debugPrintStack(stackTrace: st);

      state = state.copyWith(
        filters: state.filters.copyWith(
          isLoading: false,
          error: e,
          errorMessage: "Failed to load filters",
        ),
      );
      return false;
    }
  }

  /// ─────────────────────────────────────────────
  /// SELECT STORE
  /// ─────────────────────────────────────────────
  void selectStore(StoreDetail store) {
    state = state.copyWith(selectedStore: store);
  }
}

// ───────────────────────────────
// UTILITY FUNCTION
// ───────────────────────────────
String capitalizeWords(String input) {
  return input
      .toLowerCase()
      .split(' ')
      .map(
        (word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '',
      )
      .join(' ');
}
