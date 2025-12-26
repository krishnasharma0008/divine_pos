import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../shared/utils/api_endpointen.dart';
import '../../../shared/utils/http_client.dart';
import 'store_details.dart';

/// STATE MODEL
class StoreDetailState {
  final bool isLoading;
  final List<StoreDetail> stores; // list of all stores
  final StoreDetail? selectedStore; // currently selected store
  final Object? error;
  final String? errorMessage;

  const StoreDetailState({
    this.isLoading = false,
    this.stores = const [],
    this.selectedStore,
    this.error,
    this.errorMessage,
  });

  StoreDetailState copyWith({
    bool? isLoading,
    List<StoreDetail>? stores,
    StoreDetail? selectedStore,
    Object? error,
    String? errorMessage,
  }) {
    return StoreDetailState(
      isLoading: isLoading ?? this.isLoading,
      stores: stores ?? this.stores,
      // only override selectedStore when a non-null value is passed
      selectedStore: selectedStore ?? this.selectedStore,
      error: error,
      errorMessage: errorMessage,
    );
  }
}

/// PROVIDER
final StoreProvider =
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

      //debugPrint('getPJStore response: ${response.data}');

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

  /// Update selected store (e.g. when user taps a branch)
  void selectStore(StoreDetail store) {
    state = state.copyWith(selectedStore: store);
  }
}
