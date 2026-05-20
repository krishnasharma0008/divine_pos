import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:divine_pos/features/scan_ready/data/product_model.dart';
import 'package:divine_pos/shared/utils/api_endpointen.dart';
import 'package:divine_pos/shared/utils/http_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:divine_pos/features/auth/data/auth_notifier.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class ScanReadyState {
  final List<ProductModel> products;

  /// True while addByScannedCode is fetching.
  /// We deliberately keep the state as AsyncData the whole time so that
  /// ref.listen always sees a real product list in `previous` and never
  /// falls back to [] due to an AsyncLoading intermediate value.
  final bool isLoading;

  const ScanReadyState({this.products = const [], this.isLoading = false});

  ScanReadyState copyWith({List<ProductModel>? products, bool? isLoading}) {
    return ScanReadyState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final scanReadyProvider =
    AsyncNotifierProvider<ScanReadyNotifier, ScanReadyState>(
      ScanReadyNotifier.new,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class ScanReadyNotifier extends AsyncNotifier<ScanReadyState> {
  @override
  Future<ScanReadyState> build() async {
    return const ScanReadyState();
  }

  Future<ProductModel> addByScannedCode(String designNo) async {
    final trimmed = designNo.trim();
    if (trimmed.isEmpty) {
      throw Exception('Invalid QR code');
    }

    final current = state.asData?.value ?? const ScanReadyState();
    state = AsyncData(current.copyWith(isLoading: true));

    try {
      final items = await _fetchJewellery(itemNumber: trimmed, page: '1');

      if (items.isEmpty) {
        state = AsyncData(current.copyWith(isLoading: false));
        throw Exception('No product found for "$trimmed"');
      }

      final merged = List<ProductModel>.from(current.products);
      ProductModel? addedProduct;

      for (final item in items) {
        final exists = merged.any(
          (e) => _itemUniqueKey(e) == _itemUniqueKey(item),
        );
        if (!exists) {
          merged.add(item);
          addedProduct ??= item;
        }
      }

      if (addedProduct == null) {
        state = AsyncData(current.copyWith(isLoading: false));
        throw Exception('This product is already in the comparison');
      }

      state = AsyncData(ScanReadyState(products: merged, isLoading: false));

      return addedProduct;
    } catch (e, st) {
      state = AsyncData(current.copyWith(isLoading: false));
      Error.throwWithStackTrace(e, st);
    }
  }

  void removeProduct(ProductModel item) {
    final current = state.value ?? const ScanReadyState();
    final updated = current.products
        .where((e) => _itemUniqueKey(e) != _itemUniqueKey(item))
        .toList();
    state = AsyncData(current.copyWith(products: updated));
  }

  void clearAll() {
    state = const AsyncData(ScanReadyState());
  }

  void setProducts(List<ProductModel> products) {
    state = AsyncData(
      ScanReadyState(products: List<ProductModel>.from(products)),
    );
  }

  bool containsProduct(ProductModel item) {
    final current = state.value ?? const ScanReadyState();
    return current.products.any(
      (e) => _itemUniqueKey(e) == _itemUniqueKey(item),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _itemUniqueKey(ProductModel item) {
    final idKey = item.id.toString().trim();
    if (idKey.isNotEmpty && idKey != '0') return idKey;

    final itemNo = (item.itemno ?? '').trim();
    if (itemNo.isNotEmpty) return itemNo;

    final designNo = (item.designno ?? '').trim();
    if (designNo.isNotEmpty) return designNo;

    // final productCode = (item.productCode ?? '').trim();
    // if (productCode.isNotEmpty) return productCode;

    return item.hashCode.toString();
  }

  Future<List<ProductModel>> _fetchJewellery({
    String? page,
    String? itemNumber,
  }) async {
    try {
      final dio = ref.read(httpClientProvider);
      final authRepo = ref.read(authProvider);

      final raw = authRepo.user?.pjcode ?? '';
      final pjcode = raw.split(',').first.trim();

      final postData =
          <String, dynamic>{
            'item_number': itemNumber,
            'laying_with': pjcode,
            'page': page,
            'only_own': 1,
          }..removeWhere(
            (_, value) => value == null || value.toString().trim().isEmpty,
          );

      final response = await dio
          .post(ApiEndPoint.get_jewellery_listing, data: postData)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw TimeoutException('Request timed out after 15s'),
          );

      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }

      longPrint('📦 Fetched Listing screen Data: ${jsonEncode(response.data)}');

      if (response.data == null) {
        throw Exception('Empty response from server');
      }

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        final errorMsg = responseData['message'] ?? 'Unknown server error';
        throw Exception('Server error: $errorMsg');
      }

      final rawData = responseData['data'];
      if (rawData == null || rawData is! List || rawData.isEmpty) {
        return [];
      }

      final data = <ProductModel>[];
      for (final item in rawData) {
        try {
          if (item is Map<String, dynamic>) {
            data.add(ProductModel.fromJson(item));
          }
        } catch (e) {
          debugPrint('⚠️ Failed to parse item: $item, Error: $e');
        }
      }

      return data;
    } on DioException catch (e) {
      debugPrint('🌐 Dio Error: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Network timeout. Please check your connection.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to load jewellery: $e');
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Utilities
// ─────────────────────────────────────────────────────────────────────────────

void resetScanReadyProvider(WidgetRef ref) {
  ref.invalidate(scanReadyProvider);
}

void longPrint(Object? obj) {
  const chunkSize = 800;
  final str = obj.toString();
  for (var i = 0; i < str.length; i += chunkSize) {
    final end = (i + chunkSize < str.length) ? i + chunkSize : str.length;
    debugPrint(str.substring(i, end));
  }
}
