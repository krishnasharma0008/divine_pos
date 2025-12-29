import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/api_endpointen.dart';
import '../../../shared/utils/http_client.dart';
import 'filter_provider.dart';
import 'jewellery_model.dart';
import '../../auth/data/auth_notifier.dart';

final jewelleryProvider =
    AsyncNotifierProvider<JewelleryNotifier, List<Jewellery>>(
      JewelleryNotifier.new,
    );

class JewelleryNotifier extends AsyncNotifier<List<Jewellery>> {
  Timer? _debounce;

  int _page = 1;
  final int _limit = 8;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<Jewellery>> build() async {
    /// cleanup
    ref.onDispose(() {
      _debounce?.cancel();
    });

    /// filter change → debounce → reload
    ref.listen(filterProvider, (_, __) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), resetAndFetch);
    });

    /// initial load (page load)
    return _fetchJewellery();
  }

  /// reset + reload
  Future<void> resetAndFetch() async {
    _page = 1;
    _hasMore = true;

    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchJewellery);
  }

  /// pagination
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    _page++;

    try {
      final nextPage = await _fetchJewellery();
      state = state.whenData((current) => [...current, ...nextPage]);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<List<Jewellery>> _fetchJewellery() async {
    try {
      final dio = ref.read(httpClientProvider);
      final filter = ref.read(filterProvider);

      final authRepo = ref.read(authProvider);
      final pjcode = authRepo.user?.pjcode;

      String? layingWith;

      if (filter.isInStore) {
        layingWith = pjcode;
      } else if (filter.productBranch != null) {
        layingWith = filter.productBranch;
      } else if (filter.allDesigns) {
        layingWith = null;
      } else {
        layingWith = pjcode;
      }

      final postData = {
        "item_number": null,
        "product_category": filter.selectedCategory.isEmpty
            ? null
            : filter.selectedCategory.join(",").toLowerCase(),
        "product_sub_category": filter.selectedSubCategory.isEmpty
            ? null
            : filter.selectedSubCategory.join(","),
        "collection": null,
        "metal_purity": filter.selectedMetal.isEmpty
            ? null
            : filter.selectedMetal.first.split(' ')[0],
        "Metal_color": filter.selectedMetal.isEmpty
            ? null
            : filter.selectedMetal.first.split(' ')[1],
        "portfolio_type": null,
        "pageno": _page,
        "is_new_launch": false,
        "discarded": false,
        "gender": filter.selectedGender.isEmpty
            ? null
            : filter.selectedGender.join(","),
        "price_from": filter.selectedPriceRange.start > 0
            ? filter.selectedPriceRange.start.toInt()
            : null,

        "price_to": filter.selectedPriceRange.end > 0
            ? filter.selectedPriceRange.end.toInt()
            : null,
        "order_for": null,
        "cts_from": filter.caratStartLabel.isEmpty
            ? null
            : double.tryParse(filter.caratStartLabel),
        "cts_to": filter.caratEndLabel.isEmpty
            ? null
            : double.tryParse(filter.caratEndLabel),
        "shapes": filter.selectedShape.isEmpty
            ? null
            : filter.selectedShape.join(",").toLowerCase(),
        "occasions": filter.selectedOccasions.isEmpty
            ? null
            : filter.selectedOccasions.join(","),
        "sort_by": filter.sortBy,
        "laying_with": layingWith,
      };

      debugPrint("🔄 Fetching jewellery - Page: $_page");
      debugPrint("📦 Post Data: ${jsonEncode(postData)}");

      final response = await dio
          .post(ApiEndPoint.get_jewellery_listing, data: postData)
          .timeout(
            const Duration(seconds: 15), // ✅ Network timeout
            onTimeout: () =>
                throw TimeoutException('Request timed out after 15s'),
          );

      // ✅ HTTP Status check
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }

      // ✅ Response data validation
      if (response.data == null) {
        throw Exception('Empty response from server');
      }

      final responseData = response.data;
      if (responseData['success'] != true) {
        final errorMsg = responseData['message'] ?? 'Unknown server error';
        throw Exception('Server error: $errorMsg');
      }

      final rawData = responseData['data'];
      if (rawData == null || rawData is! List) {
        debugPrint('⚠️ No data or invalid data format: $rawData');
        _hasMore = false;
        return [];
      }

      // ✅ Safe JSON parsing
      final data = <Jewellery>[];
      for (final item in rawData) {
        try {
          if (item is Map<String, dynamic>) {
            data.add(Jewellery.fromJson(item));
          }
        } catch (e) {
          debugPrint('⚠️ Failed to parse item: $item, Error: $e');
          // Continue with next item
        }
      }

      debugPrint('✅ Loaded ${data.length} jewellery items');

      if (data.length < _limit) {
        _hasMore = false;
      }

      return data;
    } on DioException catch (e) {
      // ✅ Network/Dio specific errors
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
    } on TimeoutException catch (e) {
      debugPrint('⏰ Timeout Error: $e');
      throw Exception('Request timed out. Please try again.');
    } catch (e, stackTrace) {
      // ✅ Catch-all for unexpected errors
      debugPrint('❌ Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to load jewellery: $e');
    } finally {
      // ✅ Always update loading state
      // isLoadingNotifier.value = false; // if you have one
    }
  }

  // Future<List<Jewellery>> _fetchJewellery() async {
  //   final dio = ref.read(httpClientProvider);
  //   final filter = ref.read(filterProvider);

  //   final authRepo = ref.read(authProvider);
  //   final pjcode = authRepo.user?.pjcode;

  //   String? layingWith;

  //   if (filter.isInStore) {
  //     layingWith = pjcode;
  //   } else if (filter.productBranch != null) {
  //     layingWith = filter.productBranch;
  //   } else if (filter.allDesigns) {
  //     layingWith = null;
  //   } else {
  //     layingWith = pjcode;
  //   }

  //   // debugPrint("is_in_store: ${filter.isInStore}");
  //   // debugPrint("branch_at_code: ${filter.productBranch}");
  //   // debugPrint("all_designs: ${filter.allDesigns}");
  //   // debugPrint("sort_by: ${filter.sortBy}");

  //   //debugPrint("Selected Shape: ${filter.selectedShape}");

  //   final postData = {
  //     "item_number": null,
  //     "product_category": filter.selectedCategory.isEmpty
  //         ? null
  //         : filter.selectedCategory.join(",").toLowerCase(),
  //     "product_sub_category": filter.selectedSubCategory.isEmpty
  //         ? null
  //         : filter.selectedSubCategory.join(","),
  //     "collection": null,
  //     "metal_purity": filter.selectedMetal.isEmpty
  //         ? null
  //         : filter.selectedMetal.first.split(' ')[0],
  //     "portfolio_type": null,

  //     "pageno": _page,
  //     "is_new_launch": false,
  //     "discarded": false,

  //     "gender": filter.selectedGender.isEmpty
  //         ? null
  //         : filter.selectedGender.join(","),

  //     "price_from": null, //filter.selectedPriceRange.start,
  //     "price_to": null, //filter.selectedPriceRange.end,
  //     "order_for": null, //"Stock",
  //     "cts_from": filter.caratStartLabel.isEmpty
  //         ? null
  //         : double.tryParse(filter.caratStartLabel),

  //     "cts_to": filter.caratEndLabel.isEmpty
  //         ? null
  //         : double.tryParse(filter.caratEndLabel),

  //     //"shapes": null,
  //     "shapes": filter.selectedShape.isEmpty
  //         ? null
  //         : filter.selectedShape.join(",").toLowerCase(),
  //     "occasions": filter.selectedOccasions.isEmpty
  //         ? null
  //         : filter.selectedOccasions.join(","),
  //     "sort_by": filter.sortBy,

  //     "laying_with": layingWith,
  //   };

  //   debugPrint(" Post Data : ${postData}");

  //   final response = await dio.post(
  //     ApiEndPoint.get_jewellery_listing,
  //     data: postData,
  //   );

  //   if (response.statusCode != HttpStatus.ok ||
  //       response.data == null ||
  //       response.data["success"] != true) {
  //     throw Exception("Failed to load jewellery");
  //   }

  //   final rawData = response.data["data"];
  //   if (rawData == null || rawData is! List) {
  //     _hasMore = false;
  //     return [];
  //   }

  //   final data = rawData.map<Jewellery>((e) => Jewellery.fromJson(e)).toList();

  //   if (data.length < _limit) {
  //     _hasMore = false;
  //   }

  //   return data;
  // }
}
